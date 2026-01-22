import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/models/payment_model.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/services/payment_service.dart';
import 'package:music_app/utils/app_colors.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int selectedPlan = 1;
  PaymentModel currentUser = PaymentModel(userEmail: 'user@example.com');
  bool isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => isLoading = true);

    final clientSecret = await PaymentService.createTestPaymentIntent(
      amount: 1000,
      currency: 'USd',
    );
    if (clientSecret != null && mounted) {
      await PaymentService.showPaymentSheet(
        context: context,
        clientSecret: clientSecret,
        merchantName: 'Navakarna Test',
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to create paymentIntent',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Payment success (test mode)',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Go Premium', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => AccountScreen()),
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _premiumHeader(),
            const SizedBox(height: 30),
            _benefitsSection(),
            const SizedBox(height: 30),
            _plansSection(),
            const SizedBox(height: 30),
            _subscribeButton(),
            const SizedBox(height: 15),
            _restoreText(),
          ],
        ),
      ),
    );
  }

  Widget _premiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy unlimited music, no ads, and offline listening.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _benefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Why go Premium?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        _BenefitItem(icon: Icons.music_note, text: 'Unlimited songs'),
        _BenefitItem(icon: Icons.block, text: 'No ads'),
        _BenefitItem(icon: Icons.high_quality, text: 'High quality audio'),
      ],
    );
  }

  Widget _plansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _planCard(index: 0, title: 'Monthly', price: '₹199 / month'),
        const SizedBox(height: 12),
        _planCard(
          index: 1,
          title: 'Yearly',
          price: '₹1499 / year',
          isBest: true,
        ),
      ],
    );
  }

  Widget _planCard({
    required int index,
    required String title,
    required String price,
    bool isBest = false,
  }) {
    final isSelected = selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isBest)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subscribeButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Subscribe Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _restoreText() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Restore Purchase',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
