import 'package:flutter/material.dart';
import 'package:jisr_platform/core/constants/app_dimensions.dart';
import 'package:jisr_platform/core/decorations/app_decorations.dart';


class JisrCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const JisrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.paddingLarge),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: AppDecorations.cardDecoration(),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: content,
    );
  }
}