import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePaymentUseCase initiatePayment;
  final GetPaymentHistoryUseCase getPaymentHistory;
  final VerifyPaymentUseCase verifyPayment;

  PaymentBloc({
    required this.initiatePayment,
    required this.getPaymentHistory,
    required this.verifyPayment,
  }) : super(PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<GetPaymentHistoryEvent>(_onGetPaymentHistory);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<ResetPaymentEvent>(_onResetPayment);
    on<SelectGatewayEvent>(_onSelectGateway);
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await initiatePayment(InitiatePaymentParams(
      orderId: event.orderId,
      amount: event.amount,
      currency: event.currency,
      gateway: event.gateway,
      customerId: event.customerId,
      customerEmail: event.customerEmail,
      customerPhone: event.customerPhone,
      metadata: event.metadata,
    ));
    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (paymentResult) => emit(PaymentInitiated(result: paymentResult)),
    );
  }

  Future<void> _onGetPaymentHistory(
    GetPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentHistoryLoading());
    final result = await getPaymentHistory(GetPaymentHistoryParams(
      page: event.page,
      limit: event.limit,
      status: event.status,
      gateway: event.gateway,
    ));
    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (payments) => emit(PaymentHistoryLoaded(payments: payments, hasMore: payments.length == event.limit)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentVerifying());
    final result = await verifyPayment(VerifyPaymentParams(
      paymentId: event.paymentId,
      orderId: event.orderId,
      signature: event.signature,
      gateway: event.gateway,
    ));
    result.fold(
      (failure) => emit(PaymentVerificationFailed(message: failure.message)),
      (payment) => emit(PaymentSuccess(payment: payment)),
    );
  }

  void _onResetPayment(ResetPaymentEvent event, Emitter<PaymentState> emit) {
    emit(PaymentInitial());
  }

  void _onSelectGateway(SelectGatewayEvent event, Emitter<PaymentState> emit) {
    emit(GatewaySelected(gateway: event.gateway));
  }
}
