import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/constants/app_dimensions.dart';

class AppDecorations {
  AppDecorations._();

  static List<BoxShadow> softShadow(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.20)
            : AppColors.primaryBlue.withOpacity(
                0.06,
              ),
        blurRadius: isDark ? 12 : 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static BoxDecoration cardDecoration(
    BuildContext context, {
    double radius = AppDimensions.radiusMedium,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: colorScheme.outlineVariant,
      ),
      boxShadow: softShadow(context),
    );
  }

  static InputDecoration fieldInput(
    BuildContext context,
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryBlue.withOpacity(
          theme.brightness == Brightness.dark
              ? 0.90
              : 0.70,
        ),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 14,
      ),
      border: _fieldBorder(
        colorScheme.outlineVariant,
      ),
      enabledBorder: _fieldBorder(
        colorScheme.outlineVariant,
      ),
      focusedBorder: _fieldBorder(
        AppColors.primaryBlue,
        width: 1.4,
      ),
      errorBorder: _fieldBorder(
        AppColors.dangerRed,
        width: 1.3,
      ),
      focusedErrorBorder: _fieldBorder(
        AppColors.dangerRed,
        width: 1.4,
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        height: 1.2,
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMedium,
      ),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}