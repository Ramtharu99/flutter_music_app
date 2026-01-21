import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionTitle({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onMoreTap != null)
          InkWell(
            onTap: onMoreTap,
            child: Text('More', style: TextStyle(color: Colors.grey.shade400)),
          ),
      ],
    );
  }
}
