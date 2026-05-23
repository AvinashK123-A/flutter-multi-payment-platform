part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentVerifying extends PaymentState {}

class PaymentHistoryLoading extends PaymentState {}

class GatewaySelected extends PaymentState {
  final String gateway;
  const GatewaySelected({required this.gateway});

  @override
  List<Object?> get props => [gateway];
}

class PaymentInitiated extends PaymentState {
  final PaymentInitiationResult result;
  const PaymentInitiated({required this.result});

  @override
  List<Object?> get props => [result];
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;
  const PaymentSuccess({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  final bool hasMore;

  const PaymentHistoryLoaded({
    required this.payments,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [payments, hasMore];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentVerificationFailed extends PaymentState {
  final String message;
  const PaymentVerificationFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
