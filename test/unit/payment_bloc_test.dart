import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_multi_payment_platform/core/errors/failures.dart';
import 'package:flutter_multi_payment_platform/features/payment/domain/entities/payment_entity.dart';
import 'package:flutter_multi_payment_platform/features/payment/domain/usecases/initiate_payment_usecase.dart';
import 'package:flutter_multi_payment_platform/features/payment/domain/usecases/get_payment_history_usecase.dart';
import 'package:flutter_multi_payment_platform/features/payment/domain/usecases/verify_payment_usecase.dart';
import 'package:flutter_multi_payment_platform/features/payment/presentation/bloc/payment_bloc.dart';

import 'payment_bloc_test.mocks.dart';

@GenerateMocks([InitiatePaymentUseCase, GetPaymentHistoryUseCase, VerifyPaymentUseCase])
void main() {
  late PaymentBloc paymentBloc;
  late MockInitiatePaymentUseCase mockInitiatePayment;
  late MockGetPaymentHistoryUseCase mockGetPaymentHistory;
  late MockVerifyPaymentUseCase mockVerifyPayment;

  final tPayment = PaymentEntity(
    id: 'pay_001',
    orderId: 'ord_001',
    amount: 999.99,
    currency: 'INR',
    gateway: 'razorpay',
    status: 'success',
    createdAt: DateTime(2024, 1, 1),
    transactionId: 'txn_001',
  );

  final tInitResult = PaymentInitiationResult(
    paymentId: 'pay_001',
    orderId: 'ord_001',
    amount: 999.99,
    currency: 'INR',
    gateway: 'razorpay',
    checkoutUrl: 'https://checkout.razorpay.com/pay_001',
    gatewayData: {'key': 'test_key', 'order_id': 'ord_001'},
  );

  setUp(() {
    mockInitiatePayment = MockInitiatePaymentUseCase();
    mockGetPaymentHistory = MockGetPaymentHistoryUseCase();
    mockVerifyPayment = MockVerifyPaymentUseCase();
    paymentBloc = PaymentBloc(
      initiatePayment: mockInitiatePayment,
      getPaymentHistory: mockGetPaymentHistory,
      verifyPayment: mockVerifyPayment,
    );
  });

  tearDown(() => paymentBloc.close());

  test('initial state should be PaymentInitial', () {
    expect(paymentBloc.state, isA<PaymentInitial>());
  });

  group('InitiatePaymentEvent', () {
    blocTest<PaymentBloc, PaymentState>(
      'should emit [PaymentLoading, PaymentInitiated] when payment initiation succeeds',
      build: () {
        when(mockInitiatePayment(any)).thenAnswer((_) async => Right(tInitResult));
        return paymentBloc;
      },
      act: (bloc) => bloc.add(const InitiatePaymentEvent(
        orderId: 'ord_001',
        amount: 999.99,
        currency: 'INR',
        gateway: 'razorpay',
        customerId: 'cust_001',
        customerEmail: 'test@example.com',
      )),
      expect: () => [
        isA<PaymentLoading>(),
        isA<PaymentInitiated>(),
      ],
      verify: (_) => verify(mockInitiatePayment(any)).called(1),
    );

    blocTest<PaymentBloc, PaymentState>(
      'should emit [PaymentLoading, PaymentError] when payment initiation fails',
      build: () {
        when(mockInitiatePayment(any)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Payment gateway error')),
        );
        return paymentBloc;
      },
      act: (bloc) => bloc.add(const InitiatePaymentEvent(
        orderId: 'ord_001',
        amount: 999.99,
        currency: 'INR',
        gateway: 'razorpay',
        customerId: 'cust_001',
        customerEmail: 'test@example.com',
      )),
      expect: () => [
        isA<PaymentLoading>(),
        isA<PaymentError>(),
      ],
    );
  });

  group('GetPaymentHistoryEvent', () {
    blocTest<PaymentBloc, PaymentState>(
      'should emit [PaymentHistoryLoading, PaymentHistoryLoaded] on success',
      build: () {
        when(mockGetPaymentHistory(any)).thenAnswer(
          (_) async => Right([tPayment]),
        );
        return paymentBloc;
      },
      act: (bloc) => bloc.add(const GetPaymentHistoryEvent()),
      expect: () => [
        isA<PaymentHistoryLoading>(),
        isA<PaymentHistoryLoaded>(),
      ],
    );
  });

  group('VerifyPaymentEvent', () {
    blocTest<PaymentBloc, PaymentState>(
      'should emit [PaymentVerifying, PaymentSuccess] on successful verification',
      build: () {
        when(mockVerifyPayment(any)).thenAnswer((_) async => Right(tPayment));
        return paymentBloc;
      },
      act: (bloc) => bloc.add(const VerifyPaymentEvent(
        paymentId: 'pay_001',
        orderId: 'ord_001',
        signature: 'sig_abc123',
        gateway: 'razorpay',
      )),
      expect: () => [
        isA<PaymentVerifying>(),
        isA<PaymentSuccess>(),
      ],
    );
  });

  group('ResetPaymentEvent', () {
    blocTest<PaymentBloc, PaymentState>(
      'should emit [PaymentInitial] when reset',
      build: () => paymentBloc,
      seed: () => PaymentError(message: 'Some error'),
      act: (bloc) => bloc.add(const ResetPaymentEvent()),
      expect: () => [isA<PaymentInitial>()],
    );
  });
}
