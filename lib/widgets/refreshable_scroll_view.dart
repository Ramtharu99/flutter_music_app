import 'package:flutter/material.dart';
import 'package:music_app/utils/app_colors.dart';

class RefreshableScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color color;

  const RefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.black,
    this.color = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: backgroundColor,
      onRefresh: onRefresh,
      color: color,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    );
  }
}
