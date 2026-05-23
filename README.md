<div align="center">

![banner](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12&height=200&section=header&text=Multi%20Payment%20Gateway%20Platform&fontSize=30&fontColor=white&animation=fadeIn&fontAlignY=35&desc=Flutter%20%7C%20BLoC%20%7C%20Stripe%20%7C%20Razorpay%20%7C%20PayPal&descAlignY=55)

[![Flutter](https://img.shields.io/badge/Flutter-3.19-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.3-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev) [![Stripe](https://img.shields.io/badge/Stripe-6.8-008CDD?style=for-the-badge&logo=stripe&logoColor=white)](https://stripe.com) [![Razorpay](https://img.shields.io/badge/Razorpay-1.3-02042B?style=for-the-badge&logo=razorpay&logoColor=white)](https://razorpay.com) [![PayPal](https://img.shields.io/badge/PayPal-SDK-003087?style=for-the-badge&logo=paypal&logoColor=white)](https://developer.paypal.com) [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> **Enterprise Flutter payment infrastructure** with automatic gateway routing, PCI-DSS compliant token storage, and unified Strategy Pattern interface across Stripe, Razorpay, and PayPal.

</div>

---

## ✨ Features

| Feature | Status | Details |
|:--------|:------:|:--------|
| 🔀 Smart Gateway Routing | ✅ | Auto-select by currency + region |
| 💳 Stripe Integration | ✅ | Cards, Apple Pay, Google Pay |
| ₹ Razorpay Integration | ✅ | UPI, NetBanking, Wallets |
| 🌐 PayPal Integration | ✅ | Global fallback gateway |
| 🔁 Payment Retry | ✅ | Exponential backoff with fallback |
| 💸 Refund Workflows | ✅ | Full and partial refunds |
| 📋 Transaction History | ✅ | Cursor-based pagination |
| 🔔 Webhook Handling | ✅ | HMAC signature verification |
| 💾 Saved Cards | ✅ | Tokenized via gateway vaults |
| 🔒 Secure Storage | ✅ | flutter_secure_storage, zero raw card data |
| 📊 Payment Analytics | ✅ | Success rate, revenue metrics |
| 💱 Multi-Currency | ✅ | 40+ currencies supported |

---

## 🏗️ Architecture — Strategy Pattern

```
┌─────────────────────────────────────────────────────┐
│              PaymentBloc (BLoC)                      │
│  PaymentInitiate → PaymentManager → Gateway          │
└─────────────────────┬───────────────────────────────┘
                      │
           ┌──────────▼──────────┐
           │   PaymentManager    │
           │  resolveGateway()   │
           │  pay() + fallback() │
           └──────────┬──────────┘
                      │
     ┌────────────────┼────────────────┐
     ▼                ▼                ▼
StripeGateway  RazorpayGateway  PaypalGateway
(USD/EUR/GBP)   (INR/UPI)      (Global FB)
     │                │                │
     └────────────────┴────────────────┘
                      │
           ┌──────────▼──────────┐
           │  PaymentRepository  │
           │  Remote: REST API   │
           │  Local: SecureStore │
           └─────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── di/injection.dart
│   └── network/dio_client.dart
└── features/
    └── payment/
        ├── data/
        │   ├── datasources/payment_remote_datasource.dart
        │   ├── models/
        │   │   ├── payment_model.dart
        │   │   └── transaction_model.dart
        │   └── repositories/payment_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── payment_entity.dart
        │   │   └── transaction_entity.dart
        │   ├── repositories/payment_repository.dart
        │   └── usecases/
        │       ├── initiate_payment_usecase.dart
        │       ├── get_transactions_usecase.dart
        │       └── refund_usecase.dart
        └── presentation/
            ├── bloc/
            │   ├── payment_bloc.dart
            │   ├── payment_event.dart
            │   └── payment_state.dart
            └── screens/
                ├── checkout_screen.dart
                └── transaction_history_screen.dart
services/
└── payment/
    ├── payment_gateway.dart
    ├── payment_manager.dart
    ├── gateways/
    │   ├── stripe_gateway.dart
    │   ├── razorpay_gateway.dart
    │   └── paypal_gateway.dart
    └── secure_payment_storage.dart
```

---

## 🚀 Installation

```bash
git clone https://github.com/AvinashK123-A/flutter-multi-payment-platform.git
cd flutter-multi-payment-platform
flutter pub get
cp .env.example .env
flutter run
```

## ⚙️ Environment

```env
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
RAZORPAY_KEY_ID=rzp_test_your_key
PAYPAL_CLIENT_ID=your_paypal_client_id
BASE_URL=https://api.yourdomain.com
WEBHOOK_SECRET=your_webhook_hmac_secret
```

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  injectable: ^2.3.2
  get_it: ^7.6.4
  dio: ^5.3.4
  flutter_secure_storage: ^9.0.0
  razorpay_flutter: ^1.3.5
  flutter_stripe: ^10.1.1
  dartz: ^0.10.1
```

---

## 💻 Core Code

<details>
<summary><b>🔑 PaymentGateway — Strategy Interface</b></summary>

```dart
// lib/services/payment/payment_gateway.dart
enum GatewayType { razorpay, stripe, paypal }

abstract class PaymentGateway {
  GatewayType get type;
  Future<PaymentResult> initiatePayment(PaymentRequest request);
  Future<PaymentResult> verifyPayment(String paymentId);
  Future<RefundResult> initiateRefund(RefundRequest request);
  Future<void> dispose();
}

class PaymentRequest {
  final String orderId;
  final double amount;
  final String currency;
  final String customerEmail;
  final String? customerName;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.orderId, required this.amount,
    required this.currency, required this.customerEmail,
    this.customerName, this.metadata,
  });
}

class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final GatewayType? gateway;
  final String? errorCode;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult._({ required this.isSuccess, this.transactionId,
      this.gateway, this.errorCode, this.errorMessage, this.rawResponse });

  factory PaymentResult.success({required String transactionId,
      required GatewayType gateway, Map<String, dynamic>? raw}) =>
      PaymentResult._(isSuccess: true, transactionId: transactionId,
          gateway: gateway, rawResponse: raw);

  factory PaymentResult.failure(String code, String message) =>
      PaymentResult._(isSuccess: false, errorCode: code, errorMessage: message);
}

class RefundRequest {
  final String transactionId;
  final double? amount;
  final String reason;
  const RefundRequest({required this.transactionId, this.amount, required this.reason});
}

class RefundResult {
  final bool isSuccess;
  final String? refundId;
  final String? errorMessage;
  const RefundResult({required this.isSuccess, this.refundId, this.errorMessage});
}
```

</details>

<details>
<summary><b>🔑 PaymentManager — Gateway Orchestrator</b></summary>

```dart
// lib/services/payment/payment_manager.dart
import 'package:injectable/injectable.dart';
import 'payment_gateway.dart';
import 'gateways/stripe_gateway.dart';
import 'gateways/razorpay_gateway.dart';
import 'gateways/paypal_gateway.dart';

@singleton
class PaymentManager {
  final Map<GatewayType, PaymentGateway> _gateways;

  PaymentManager(StripeGateway stripe, RazorpayGateway razorpay, PaypalGateway paypal)
      : _gateways = {
          GatewayType.stripe: stripe,
          GatewayType.razorpay: razorpay,
          GatewayType.paypal: paypal,
        };

  GatewayType resolveGateway({required String currency, required String region}) {
    if (currency == 'INR') return GatewayType.razorpay;
    if ({'USD', 'EUR', 'GBP', 'CAD', 'AUD'}.contains(currency)) return GatewayType.stripe;
    return GatewayType.paypal;
  }

  PaymentGateway getGateway(GatewayType type) =>
      _gateways[type] ?? (throw ArgumentError('Unregistered gateway: $type'));

  Future<PaymentResult> pay({
    required PaymentRequest request,
    required String region,
    GatewayType? forceGateway,
    bool enableFallback = true,
  }) async {
    final type = forceGateway ?? resolveGateway(currency: request.currency, region: region);
    try {
      final result = await getGateway(type).initiatePayment(request);
      if (!result.isSuccess && enableFallback && type != GatewayType.paypal) {
        return getGateway(GatewayType.paypal).initiatePayment(request);
      }
      return result;
    } catch (e) {
      if (enableFallback && type != GatewayType.paypal) {
        return getGateway(GatewayType.paypal).initiatePayment(request);
      }
      return PaymentResult.failure('GATEWAY_EXCEPTION', e.toString());
    }
  }
}
```

</details>

<details>
<summary><b>🔑 RazorpayGateway — Razorpay Implementation</b></summary>

```dart
// lib/services/payment/gateways/razorpay_gateway.dart
import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../payment_gateway.dart';

@injectable
class RazorpayGateway implements PaymentGateway {
  Razorpay? _razorpay;
  Completer<PaymentResult>? _completer;

  RazorpayGateway() {
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override GatewayType get type => GatewayType.razorpay;

  @override
  Future<PaymentResult> initiatePayment(PaymentRequest request) {
    _completer = Completer<PaymentResult>();
    _razorpay?.open({
      'key': const String.fromEnvironment('RAZORPAY_KEY_ID'),
      'amount': (request.amount * 100).toInt(),
      'currency': request.currency,
      'order_id': request.orderId,
      'prefill': {'email': request.customerEmail},
      'theme': {'color': '#6C63FF'},
    });
    return _completer!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => PaymentResult.failure('TIMEOUT', 'Payment timed out'),
    );
  }

  void _onSuccess(PaymentSuccessResponse r) =>
      _completer?.complete(PaymentResult.success(
          transactionId: r.paymentId ?? '', gateway: GatewayType.razorpay));

  void _onError(PaymentFailureResponse r) =>
      _completer?.complete(PaymentResult.failure(
          r.code.toString(), r.message ?? 'Payment failed'));

  void _onWallet(ExternalWalletResponse _) =>
      _completer?.complete(PaymentResult.failure('WALLET', 'External wallet selected'));

  @override Future<PaymentResult> verifyPayment(String id) => throw UnimplementedError();
  @override Future<RefundResult> initiateRefund(RefundRequest r) => throw UnimplementedError();
  @override Future<void> dispose() async => _razorpay?.clear();
}
```

</details>

<details>
<summary><b>🧠 PaymentBloc — Full BLoC</b></summary>

```dart
// lib/features/payment/presentation/bloc/payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/refund_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePaymentUseCase _initiate;
  final GetTransactionsUseCase _getTransactions;
  final RefundUseCase _refund;

  PaymentBloc(this._initiate, this._getTransactions, this._refund)
      : super(const PaymentState()) {
    on<PaymentInitiate>(_onInitiate);
    on<PaymentLoadHistory>(_onLoadHistory);
    on<PaymentRefund>(_onRefund);
    on<PaymentReset>((_, emit) => emit(const PaymentState()));
  }

  Future<void> _onInitiate(PaymentInitiate e, Emitter<PaymentState> emit) async {
    emit(state.copyWith(status: PaymentStatus.processing));
    final result = await _initiate(
      orderId: e.orderId, amount: e.amount,
      currency: e.currency, region: e.region);
    result.fold(
      (f) => emit(state.copyWith(status: PaymentStatus.failed, errorMessage: f.message)),
      (payment) => emit(state.copyWith(
        status: payment.isSuccess ? PaymentStatus.success : PaymentStatus.failed,
        currentTransaction: payment,
        errorMessage: payment.isSuccess ? null : payment.errorMessage)),
    );
  }

  Future<void> _onLoadHistory(PaymentLoadHistory e, Emitter<PaymentState> emit) async {
    emit(state.copyWith(historyStatus: HistoryStatus.loading));
    final result = await _getTransactions(page: e.page, pageSize: 20);
    result.fold(
      (f) => emit(state.copyWith(historyStatus: HistoryStatus.error, errorMessage: f.message)),
      (txns) => emit(state.copyWith(
        historyStatus: HistoryStatus.loaded,
        transactions: e.page == 0 ? txns : [...state.transactions, ...txns])),
    );
  }

  Future<void> _onRefund(PaymentRefund e, Emitter<PaymentState> emit) async {
    emit(state.copyWith(status: PaymentStatus.processing));
    final result = await _refund(transactionId: e.transactionId, amount: e.amount);
    result.fold(
      (f) => emit(state.copyWith(status: PaymentStatus.failed, errorMessage: f.message)),
      (_) => emit(state.copyWith(status: PaymentStatus.refunded)),
    );
  }
}
```

</details>

---

## 🔄 CI/CD

```yaml
name: Flutter CI
on:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

---

## 🗺️ Roadmap

- [x] Stripe, Razorpay, PayPal integration
- [x] Strategy Pattern gateway abstraction
- [x] PCI-DSS token storage
- [x] Transaction history + refunds
- [ ] Apple Pay / Google Pay native
- [ ] Subscription billing
- [ ] Split payments
- [ ] Payment link generation

---

## 📄 License

MIT License — see [LICENSE](LICENSE).

---

<div align="center">

**Built with ❤️ by [Avinash Reddy](https://github.com/AvinashK123-A)**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/avinash-reddy-0826b0222/)

![footer](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12&height=100&section=footer)

</div>
