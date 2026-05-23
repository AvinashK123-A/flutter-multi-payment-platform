import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'injection.config.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/initiate_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_payment_history_usecase.dart';
import '../../features/payment/domain/usecases/verify_payment_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart_usecase.dart';
import '../../features/cart/domain/usecases/remove_from_cart_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_usecase.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  _registerNetworking();
  _registerStorage();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerNetworking() {
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}

void _registerStorage() {
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorageImpl());
}

void _registerDataSources() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(storage: getIt<LocalStorage>()),
  );
}

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: getIt<PaymentRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: getIt<CartLocalDataSource>()),
  );
}

void _registerUseCases() {
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => InitiatePaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(() => GetPaymentHistoryUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(() => VerifyPaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(() => AddToCartUseCase(getIt<CartRepository>()));
  getIt.registerLazySingleton(() => RemoveFromCartUseCase(getIt<CartRepository>()));
  getIt.registerLazySingleton(() => GetCartUseCase(getIt<CartRepository>()));
}

void _registerBlocs() {
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
  getIt.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      initiatePayment: getIt<InitiatePaymentUseCase>(),
      getPaymentHistory: getIt<GetPaymentHistoryUseCase>(),
      verifyPayment: getIt<VerifyPaymentUseCase>(),
    ),
  );
  getIt.registerFactory<CartBloc>(
    () => CartBloc(
      addToCart: getIt<AddToCartUseCase>(),
      removeFromCart: getIt<RemoveFromCartUseCase>(),
      getCart: getIt<GetCartUseCase>(),
    ),
  );
}
