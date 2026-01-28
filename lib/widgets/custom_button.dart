import 'package:flutter/material.dart';
import 'package:music_app/utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final bool isLoading;
  final String priceText;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.isLoading,
    required this.priceText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Subscribe for $priceText',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
