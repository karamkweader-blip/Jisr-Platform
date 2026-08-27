import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/decorations/app_decorations.dart';

class JisrSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const JisrSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<JisrSearchField> createState() {
    return _JisrSearchFieldState();
  }
}

class _JisrSearchFieldState
    extends State<JisrSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
      _updateClearButton,
    );
  }

  @override
  void didUpdateWidget(
    covariant JisrSearchField oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller ==
        widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(
      _updateClearButton,
    );

    widget.controller.addListener(
      _updateClearButton,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _updateClearButton,
    );

    super.dispose();
  }

  void _updateClearButton() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            AppDecorations.softShadow(context),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        cursorColor: AppColors.primaryBlue,
        style: TextStyle(
          color: colorScheme.onSurface,
        ),
        decoration: AppDecorations.fieldInput(
          context,
          widget.hintText,
          Icons.search_rounded,
          suffixIcon:
              widget.controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'مسح البحث',
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                ),
        ),
      ),
    );
  }
}