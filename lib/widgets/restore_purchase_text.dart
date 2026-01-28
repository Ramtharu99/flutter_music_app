import 'package:flutter/material.dart';

class RestorePurchaseText extends StatelessWidget {
  final VoidCallback onPressed;

  const RestorePurchaseText({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          'Restore Purchase',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
