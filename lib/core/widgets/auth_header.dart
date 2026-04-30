import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;

  final double spaceAfterLogo;
  final double spaceAfterTitle;

  final bool useHero;
  final bool logoWithContainer;
  final double logoContainerSize;
  final EdgeInsetsGeometry logoPadding;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 95,
    this.titleFontSize = 26,
    this.subtitleFontSize = 14,
    this.spaceAfterLogo = 28,
    this.spaceAfterTitle = 8,
    this.useHero = true,
    this.logoWithContainer = false,
    this.logoContainerSize = 78,
    this.logoPadding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/images/logo.png',
      height: logoSize,
      fit: BoxFit.contain,
    );

    if (logoWithContainer) {
      logo = Container(
        width: logoContainerSize,
        height: logoContainerSize,
        padding: logoPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      );
    } else {
      logo = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.10),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: logo,
      );
    }

    return Column(
      children: [
        useHero ? Hero(tag: 'logo', child: logo) : logo,
        SizedBox(height: spaceAfterLogo),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: spaceAfterTitle),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: subtitleFontSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}