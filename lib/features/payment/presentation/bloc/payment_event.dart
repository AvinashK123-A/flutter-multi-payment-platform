part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitiatePaymentEvent extends PaymentEvent {
  final String orderId;
  final double amount;
  final String currency;
  final String gateway;
  final String customerId;
  final String customerEmail;
  final String? customerPhone;
  final Map<String, dynamic>? metadata;

  const InitiatePaymentEvent({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.customerId,
    required this.customerEmail,
    this.customerPhone,
    this.metadata,
  });

  @override
  List<Object?> get props => [orderId, amount, currency, gateway, customerId, customerEmail];
}

class GetPaymentHistoryEvent extends PaymentEvent {
  final int page;
  final int limit;
  final String? status;
  final String? gateway;

  const GetPaymentHistoryEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.gateway,
  });

  @override
  List<Object?> get props => [page, limit, status, gateway];
}

class VerifyPaymentEvent extends PaymentEvent {
  final String paymentId;
  final String orderId;
  final String signature;
  final String gateway;

  const VerifyPaymentEvent({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.gateway,
  });

  @override
  List<Object?> get props => [paymentId, orderId, signature, gateway];
}

class ResetPaymentEvent extends PaymentEvent {
  const ResetPaymentEvent();
}

class SelectGatewayEvent extends PaymentEvent {
  final String gateway;
  const SelectGatewayEvent({required this.gateway});

  @override
  List<Object?> get props => [gateway];
}
