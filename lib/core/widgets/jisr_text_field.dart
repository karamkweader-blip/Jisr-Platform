import 'package:flutter/material.dart';
import 'package:jisr_platform/core/decorations/app_decorations.dart';

class JisrTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  const JisrTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: AppDecorations.softShadow,
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: AppDecorations.fieldInput(hintText, icon).copyWith(
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}