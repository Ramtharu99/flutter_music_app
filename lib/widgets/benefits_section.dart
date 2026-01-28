import 'package:flutter/material.dart';
import 'package:music_app/widgets/benefit_item.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        BenefitItem(icon: Icons.music_note, text: 'Unlimited songs'),
        BenefitItem(icon: Icons.block, text: 'No ads'),
        BenefitItem(icon: Icons.high_quality, text: 'High quality audio'),
      ],
    );
  }
}
