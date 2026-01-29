import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/models/payment_model.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/services/payment_service.dart';
import 'package:music_app/widgets/benefits_section.dart';
import 'package:music_app/widgets/custom_button.dart';
import 'package:music_app/widgets/plans_section.dart';
// Widgets
import 'package:music_app/widgets/premium_header.dart';
import 'package:music_app/widgets/restore_purchase_text.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int selectedPlan = 1;
  bool isLoading = false;

  final PaymentModel currentUser = PaymentModel(userEmail: 'user@example.com');

  int get selectedAmount {
    return selectedPlan == 0 ? 499 : 2999;
  }

  String get selectedPriceText {
    return selectedPlan == 0 ? '\$4.99 / month' : '\$29.99 / year';
  }

  Future<void> _handlePayment() async {
    setState(() => isLoading = true);

    try {
      final clientSecret = await PaymentService.createTestPaymentIntent(
        amount: selectedAmount,
        currency: 'USD',
      );

      if (clientSecret == null) {
        debugPrint('Failed payment');
        return;
      }

      await PaymentService.showPaymentSheet(
        context: context,
        clientSecret: clientSecret,
        merchantName: 'Navakarna Music',
      );

      debugPrint('payment success');
    } catch (e) {
      debugPrint('Something went wrong');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Go Premium', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const AccountScreen()),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumHeader(),
            const SizedBox(height: 30),
            const BenefitsSection(),
            const SizedBox(height: 30),
            PlansSection(
              selectedPlan: selectedPlan,
              onPlanSelected: (index) {
                setState(() => selectedPlan = index);
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              isLoading: isLoading,
              priceText: selectedPriceText,
              onPressed: _handlePayment,
            ),
            const SizedBox(height: 15),
            RestorePurchaseText(onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
