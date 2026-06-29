import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class JisrAnimatedLogo extends StatefulWidget {
  final double size;
  final String assetPath;

  const JisrAnimatedLogo({
    super.key,
    this.size = 46,
    this.assetPath = 'assets/images/logo.png',
  });

  @override
  State<JisrAnimatedLogo> createState() => _JisrAnimatedLogoState();
}

class _JisrAnimatedLogoState extends State<JisrAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerSize = widget.size + 10;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: outerSize,
                  height: outerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.00),
                        AppColors.primaryBlue.withOpacity(0.35),
                        AppColors.actionYellow.withOpacity(0.50),
                        AppColors.primaryBlue.withOpacity(0.25),
                        AppColors.primaryBlue.withOpacity(0.00),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.actionYellow.withOpacity(.14),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              ClipOval(
                child: Container(
                  width: widget.size - 4,
                  height: widget.size - 4,
                  padding: const EdgeInsets.all(4),
                  color: Colors.white,
                  child: Image.asset(
                    widget.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.actionYellow,
                        size: 26,
                      );
                    },
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.045, 1.045),
                    duration: 1700.ms,
                    curve: Curves.easeInOut,
                  )
                  .shimmer(
                    duration: 2200.ms,
                    color: AppColors.actionYellow.withOpacity(.22),
                  ),
            ],
          );
        },
      ),
    );
  }
}