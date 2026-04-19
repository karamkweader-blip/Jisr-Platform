import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class RegisterStepActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const RegisterStepActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(18);

    if (isPrimary) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.20),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon ?? Icons.arrow_forward_rounded, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon ?? Icons.arrow_back_rounded,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.primaryBlue.withOpacity(0.18),
            width: 1.4,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}