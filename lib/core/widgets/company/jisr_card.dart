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
    this.padding = const EdgeInsets.all(
      AppDimensions.paddingLarge,
    ),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      AppDimensions.radiusMedium,
    );

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration:
          AppDecorations.cardDecoration(context),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      ),
    );
  }
}