import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      scaffoldBackground: AppColors.background,
      surface: AppColors.cardWhite,
      surfaceContainer: AppColors.lightSurfaceContainer,
      textColor: AppColors.textDark,
      mutedTextColor: AppColors.textGrey,
      borderColor: AppColors.lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      scaffoldBackground: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurfaceContainer,
      textColor: AppColors.darkText,
      mutedTextColor: AppColors.darkTextGrey,
      borderColor: AppColors.darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surface,
    required Color surfaceContainer,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.actionYellow,
      onSecondary: const Color(0xFF241A00),
      error: AppColors.dangerRed,
      onError: Colors.white,
      surface: surface,
      onSurface: textColor,
      surfaceContainer: surfaceContainer,
      outline: borderColor,
      outlineVariant: borderColor.withOpacity(0.65),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      colorScheme: colorScheme,
    );

    final textTheme = baseTheme.textTheme.apply(
      fontFamily: 'Cairo',
      bodyColor: textColor,
      displayColor: textColor,
    );

    return baseTheme.copyWith(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      cardColor: surface,
      dividerColor: borderColor,

      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.5,
          color: textColor,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.4,
          color: mutedTextColor,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: mutedTextColor,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: scaffoldBackground,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.primaryBlue,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.primaryBlue,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        scrimColor: Colors.black.withOpacity(0.45),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: mutedTextColor,
          fontSize: 13,
          height: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        labelStyle: TextStyle(color: mutedTextColor),
        hintStyle: TextStyle(color: mutedTextColor),
        helperStyle: TextStyle(color: mutedTextColor),
        prefixIconColor: mutedTextColor,
        suffixIconColor: mutedTextColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _inputBorder(borderColor),
        enabledBorder: _inputBorder(borderColor),
        focusedBorder: _inputBorder(
          AppColors.primaryBlue,
          width: 1.5,
        ),
        errorBorder: _inputBorder(
          AppColors.dangerRed,
        ),
        focusedErrorBorder: _inputBorder(
          AppColors.dangerRed,
          width: 1.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              mutedTextColor.withOpacity(0.25),
          disabledForegroundColor:
              mutedTextColor.withOpacity(0.75),
          minimumSize: const Size(0, 50),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size(0, 50),
          side: BorderSide(color: borderColor),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceContainer,
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: textColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
      ),

      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),

      iconTheme: IconThemeData(
        color: mutedTextColor,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primaryBlue,
        textColor: textColor,
        subtitleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: mutedTextColor,
          fontSize: 12,
        ),
      ),

      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: surfaceContainer,
        selectedColor:
            AppColors.primaryBlue.withOpacity(0.14),
        disabledColor: surfaceContainer.withOpacity(0.55),
        side: BorderSide(color: borderColor),
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBlue;
            }

            return Colors.transparent;
          },
        ),
        checkColor: const WidgetStatePropertyAll<Color>(
          Colors.white,
        ),
        side: BorderSide(color: borderColor),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.actionYellow;
            }

            return mutedTextColor;
          },
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return mutedTextColor;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBlue;
            }

            return borderColor;
          },
        ),
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor:
            mutedTextColor.withOpacity(0.78),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
            AppColors.primaryBlue.withOpacity(0.14),
        iconTheme:
            WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryBlue
                  : mutedTextColor,
            );
          },
        ),
        labelTextStyle:
            WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            final selected =
                states.contains(WidgetState.selected);

            return TextStyle(
              fontFamily: 'Cairo',
              color: selected
                  ? AppColors.primaryBlue
                  : mutedTextColor,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            );
          },
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}