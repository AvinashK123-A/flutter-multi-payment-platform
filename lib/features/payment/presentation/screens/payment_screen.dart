import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../bloc/payment_bloc.dart';
import '../widgets/gateway_selector_widget.dart';
import '../widgets/payment_summary_card.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String currency;
  final String productName;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.productName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedGateway = 'razorpay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentInitiated) {
            context.push('/payment/checkout', extra: state.result);
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is PaymentLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaymentSummaryCard(
                    productName: widget.productName,
                    amount: widget.amount,
                    currency: widget.currency,
                    orderId: widget.orderId,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GatewaySelectorWidget(
                    selectedGateway: _selectedGateway,
                    onGatewaySelected: (gateway) {
                      setState(() => _selectedGateway = gateway);
                      context.read<PaymentBloc>().add(
                        SelectGatewayEvent(gateway: gateway),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Pay ${widget.currency.toUpperCase()} ${widget.amount.toStringAsFixed(2)}',
                    onPressed: () {
                      context.read<PaymentBloc>().add(
                        InitiatePaymentEvent(
                          orderId: widget.orderId,
                          amount: widget.amount,
                          currency: widget.currency,
                          gateway: _selectedGateway,
                          customerId: 'user_id',
                          customerEmail: 'user@example.com',
                        ),
                      );
                    },
                    isLoading: state is PaymentLoading,
                    icon: Icons.lock_rounded,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security_rounded, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          '256-bit SSL Encryption · PCI DSS Compliant',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
