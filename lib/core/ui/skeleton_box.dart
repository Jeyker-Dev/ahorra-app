import 'package:ahorra_app/core/ui/ahorra_theme.dart';
import 'package:flutter/material.dart';

/// Calm tonal placeholder block used for loading skeletons (never a spinner).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AhorraTheme.cardRadius,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.ahorraColors.surfaceHigh,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
