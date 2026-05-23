import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final String gateway;
  final String status;
  final DateTime createdAt;
  final String? transactionId;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  const PaymentEntity({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.failureReason,
    this.metadata,
  });

  bool get isSuccessful => status == 'success';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isFailed => status == 'failed' || status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  String get formattedAmount => '${currency.toUpperCase()} ${amount.toStringAsFixed(2)}';

  PaymentEntity copyWith({
    String? id,
    String? orderId,
    double? amount,
    String? currency,
    String? gateway,
    String? status,
    DateTime? createdAt,
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      gateway: gateway ?? this.gateway,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      transactionId: transactionId ?? this.transactionId,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id, orderId, amount, currency, gateway, status, createdAt,
    transactionId, failureReason, metadata,
  ];
}

class PaymentInitiationResult extends Equatable {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final String gateway;
  final String checkoutUrl;
  final Map<String, dynamic> gatewayData;

  const PaymentInitiationResult({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.checkoutUrl,
    required this.gatewayData,
  });

  @override
  List<Object?> get props => [paymentId, orderId, amount, currency, gateway, checkoutUrl, gatewayData];
}
