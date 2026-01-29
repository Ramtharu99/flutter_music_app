// widgets/plans_section.dart
// Updated to use formattedPrice for the price string

import 'package:flutter/material.dart';
import 'package:music_app/models/plan_model.dart';
import 'package:music_app/widgets/plan_card.dart';

class PlansSection extends StatelessWidget {
  final List<PlanModel> plans; // list of plans from API
  final int selectedPlanIndex;
  final Function(int) onPlanSelected;

  const PlansSection({
    super.key,
    required this.plans,
    required this.selectedPlanIndex,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        // Dynamically generate plan cards
        ...List.generate(plans.length, (index) {
          final plan = plans[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlanCard(
              title: plan.name,
              price: '${plan.formattedPrice} / ${plan.billingPeriodText}',
              isBest: plan.isFeatured,
              isSelected: selectedPlanIndex == index,
              onTap: () => onPlanSelected(index),
              features: plan.features,
              trialDays: plan.trialDays,
            ),
          );
        }),
      ],
    );
  }
}
