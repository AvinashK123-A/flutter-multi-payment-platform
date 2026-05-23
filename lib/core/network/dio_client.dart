import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../storage/local_storage.dart';
import '../../core/di/injection.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? AppConstants.defaultBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _initInterceptors();
  }

  Dio get dio => _dio;

  void _initInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      if (const bool.fromEnvironment('dart.vm.product') == false)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final storage = getIt<LocalStorage>();
      final token = await storage.getString(AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final storage = getIt<LocalStorage>();
        final refreshToken = await storage.getString(AppConstants.refreshTokenKey);
        if (refreshToken != null) {
          final dio = Dio();
          final baseUrl = dotenv.env['API_BASE_URL'] ?? AppConstants.defaultBaseUrl;
          final response = await dio.post(
            '$baseUrl/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data['access_token'];
          await storage.setString(AppConstants.accessTokenKey, newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final clonedRequest = await dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          return handler.resolve(clonedRequest);
        }
      } catch (_) {
        await _clearAndLogout();
      }
    }
    handler.next(err);
  }

  Future<void> _clearAndLogout() async {
    try {
      final storage = getIt<LocalStorage>();
      await storage.clear();
    } catch (_) {}
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = TimeoutException(message: 'Connection timed out. Please try again.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data?['message'] ?? 'Server error occurred';
        switch (statusCode) {
          case 400: appException = BadRequestException(message: message); break;
          case 401: appException = UnauthorizedException(message: message); break;
          case 403: appException = ForbiddenException(message: message); break;
          case 404: appException = NotFoundException(message: message); break;
          case 422: appException = ValidationException(message: message, errors: err.response?.data?['errors']); break;
          case 429: appException = RateLimitException(message: 'Too many requests. Please wait.'); break;
          default: appException = ServerException(message: message, statusCode: statusCode);
        }
        break;
      case DioExceptionType.cancel:
        appException = RequestCancelledException(message: 'Request was cancelled');
        break;
      default:
        appException = NetworkException(message: 'No internet connection. Please check your network.');
    }
    handler.reject(DioException(requestOptions: err.requestOptions, error: appException));
  }
}
