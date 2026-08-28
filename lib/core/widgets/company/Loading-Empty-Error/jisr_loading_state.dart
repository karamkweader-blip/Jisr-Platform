import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class JisrLoadingState extends StatelessWidget {
  final String? message;

  const JisrLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 2.4,
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}