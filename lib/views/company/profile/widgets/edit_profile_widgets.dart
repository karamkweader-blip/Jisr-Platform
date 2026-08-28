import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class EditHeader extends StatelessWidget {
  const EditHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue
                .withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'حدّث بيانات شركتك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'سيتم إرسال الحقول التي قمت بتعديلها فقط.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ProfileInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: AppColors.primaryBlue,
      style: TextStyle(
        color: colorScheme.onSurface,
      ),
      autovalidateMode:
          AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue
              .withOpacity(0.75),
          size: 20,
        ),
        filled: true,
        fillColor:
            colorScheme.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
        border: _border(
          colorScheme.outlineVariant,
        ),
        enabledBorder: _border(
          colorScheme.outlineVariant,
        ),
        focusedBorder: _border(
          AppColors.primaryBlue,
          width: 1.4,
        ),
        errorBorder: _border(
          AppColors.dangerRed,
          width: 1.2,
        ),
        focusedErrorBorder: _border(
          AppColors.dangerRed,
          width: 1.3,
        ),
      ),
    );
  }

  OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}