import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final bool isStrong;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 14.0,
    this.isStrong = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isStrong ? 32.0 : 20.0,
          sigmaY: isStrong ? 32.0 : 20.0,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.card.withOpacity(isStrong ? 0.88 : 0.70),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppTheme.border.withOpacity(isStrong ? 0.40 : 0.50),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
