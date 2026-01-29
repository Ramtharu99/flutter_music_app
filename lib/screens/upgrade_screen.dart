import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/core/api/api.dart';
import 'package:music_app/models/payment_model.dart';
import 'package:music_app/models/plan_model.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/services/payment_service.dart';
import 'package:music_app/services/plan_service.dart';
import 'package:music_app/widgets/custom_button.dart';
import 'package:music_app/widgets/plans_section.dart';
import 'package:music_app/widgets/restore_purchase_text.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  List<PlanModel> plans = [];
  int selectedIndex = 0;
  bool isLoadingPlans = true;
  bool isLoading = false;

  final PaymentModel currentUser = PaymentModel(userEmail: 'user@example.com');

  int get selectedAmount {
    if (plans.isEmpty) return 0;
    return (double.parse(plans[selectedIndex].price) * 100).toInt();
  }

  String get selectedPriceText {
    if (plans.isEmpty) return '';
    return '${plans[selectedIndex].formattedPrice} / ${plans[selectedIndex].billingPeriodText}';
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Upgrade Screen inti = ${ApiConfig.getPlans}');
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final fetchedPlans = await PlanService.fetchPlans();
      debugPrint('Fetched ${fetchedPlans.length} plans:');
      for (var plan in fetchedPlans) {
        debugPrint('-------------------');
        debugPrint('ID: ${plan.id}');
        debugPrint('Name: ${plan.name}');
        debugPrint('Price: ${plan.formattedPrice}');
        debugPrint('Period: ${plan.billingPeriodText}');
        debugPrint('Featured: ${plan.isFeatured}');
        debugPrint('Trial: ${plan.trialDays} days');
        debugPrint('Features: ${plan.features.join(", ")}');
        debugPrint('Stripe Price ID: ${plan.stripePriceId}');
      }

      setState(() {
        plans = fetchedPlans;
        isLoadingPlans = false;
      });
    } catch (e, stack) {
      debugPrint('Error fetching plans: $e');
      debugPrint('$stack');
      setState(() => isLoadingPlans = false);
    }
  }

  Future<void> _handlePayment() async {
    if (plans.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final clientSecret = await PaymentService.createTestPaymentIntent(
        amount: selectedAmount,
        currency: 'USD',
      );

      if (clientSecret == null) {
        debugPrint('Failed to create payment intent');
        return;
      }

      await PaymentService.showPaymentSheet(
        context: context,
        clientSecret: clientSecret,
        merchantName: 'Navakarna Music',
      );

      debugPrint('Payment success');
    } catch (e) {
      debugPrint('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'UpgradeScreen BUILD → plans.length = ${plans.length} | isLoadingPlans = $isLoadingPlans | selectedIndex = $selectedIndex',
    );

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
            /*const PremiumHeader(),
            const SizedBox(height: 30),
            const BenefitsSection(),
            const SizedBox(height: 30),*/
            if (isLoadingPlans)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (plans.isEmpty)
              const Center(
                child: Text(
                  'No plans available',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            else
              PlansSection(
                plans: plans,
                selectedPlanIndex: selectedIndex,
                onPlanSelected: (index) {
                  setState(() => selectedIndex = index);
                },
              ),

            const SizedBox(height: 30),

            if (!isLoadingPlans && plans.isNotEmpty)
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
