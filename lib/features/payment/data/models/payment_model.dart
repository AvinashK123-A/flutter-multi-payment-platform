import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_entity.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.gateway,
    required super.status,
    required super.createdAt,
    super.transactionId,
    super.failureReason,
    super.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  factory PaymentModel.fromEntity(PaymentEntity entity) => PaymentModel(
    id: entity.id,
    orderId: entity.orderId,
    amount: entity.amount,
    currency: entity.currency,
    gateway: entity.gateway,
    status: entity.status,
    createdAt: entity.createdAt,
    transactionId: entity.transactionId,
    failureReason: entity.failureReason,
    metadata: entity.metadata,
  );
}

@JsonSerializable()
class PaymentRequestModel {
  @JsonKey(name: 'order_id')
  final String orderId;
  final double amount;
  final String currency;
  final String gateway;
  @JsonKey(name: 'customer_id')
  final String customerId;
  @JsonKey(name: 'customer_email')
  final String customerEmail;
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  final Map<String, dynamic>? metadata;

  const PaymentRequestModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.customerId,
    required this.customerEmail,
    this.customerPhone,
    this.metadata,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestModelToJson(this);
}

@JsonSerializable()
class PaymentVerificationModel {
  @JsonKey(name: 'payment_id')
  final String paymentId;
  @JsonKey(name: 'order_id')
  final String orderId;
  final String signature;
  final String gateway;

  const PaymentVerificationModel({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.gateway,
  });

  factory PaymentVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentVerificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentVerificationModelToJson(this);
}

enum PaymentGateway {
  @JsonValue('razorpay') razorpay,
  @JsonValue('stripe') stripe,
  @JsonValue('paypal') paypal,
  @JsonValue('paytm') paytm,
}

enum PaymentStatus {
  @JsonValue('pending') pending,
  @JsonValue('processing') processing,
  @JsonValue('success') success,
  @JsonValue('failed') failed,
  @JsonValue('refunded') refunded,
  @JsonValue('cancelled') cancelled,
}
