import 'package:flutter/material.dart';
import 'package:music_app/widgets/plan_card.dart';

class PlansSection extends StatelessWidget {
  final int selectedPlan;
  final Function(int) onPlanSelected;

  const PlansSection({
    super.key,
    required this.selectedPlan,
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
        PlanCard(
          title: 'Monthly',
          price: '\$4.99 / month',
          isSelected: selectedPlan == 0,
          onTap: () => onPlanSelected(0),
        ),
        const SizedBox(height: 12),
        PlanCard(
          title: 'Yearly',
          price: '\$29.99 / year',
          isBest: true,
          isSelected: selectedPlan == 1,
          onTap: () => onPlanSelected(1),
        ),
      ],
    );
  }
}
