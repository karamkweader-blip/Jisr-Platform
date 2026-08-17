import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class CompanyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CompanyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int _searchIndex = 0;
  static const int _opportunitiesIndex = 1;
  static const int _homeIndex = 2;
  static const int _conversationsIndex = 3;
  static const int _profileIndex = 4;

  void _handleTap(int index) {
    if (currentIndex == index) {
      return;
    }

    HapticFeedback.selectionClick();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 94,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 14,
                right: 14,
                top: 18,
                bottom: 7,
                child: CustomPaint(
                  painter: _FloatingDockPainter(
                    isHomeSelected:
                        currentIndex == _homeIndex,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DockNavigationItem(
                            label: 'البحث',
                            icon: Icons.search,
                            selectedIcon: Icons.search,
                            isSelected:
                                currentIndex == _searchIndex,
                            onTap: () {
                              _handleTap(_searchIndex);
                            },
                          ),
                        ),
                        Expanded(
                          child: _DockNavigationItem(
                            label: 'الفرص',
                            icon: Icons.work_outline,
                            selectedIcon: Icons.work,
                            isSelected: currentIndex ==
                                _opportunitiesIndex,
                            onTap: () {
                              _handleTap(
                                _opportunitiesIndex,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 76),
                        Expanded(
                          child: _DockNavigationItem(
                            label: 'الرسائل',
                            icon:
                                Icons.chat_bubble_outline,
                            selectedIcon: Icons.chat,
                            isSelected: currentIndex ==
                                _conversationsIndex,
                            onTap: () {
                              _handleTap(
                                _conversationsIndex,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _DockNavigationItem(
                            label: 'الملف',
                            icon:
                                Icons.business_outlined,
                            selectedIcon:
                                Icons.business,
                            isSelected:
                                currentIndex == _profileIndex,
                            onTap: () {
                              _handleTap(_profileIndex);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: _HomeOrbButton(
                  isSelected:
                      currentIndex == _homeIndex,
                  onTap: () {
                    _handleTap(_homeIndex);
                  },
                ),
              ),
              Positioned(
                bottom: 9,
                child: IgnorePointer(
                  child: AnimatedDefaultTextStyle(
                    duration:
                        const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: currentIndex == _homeIndex
                          ? AppColors.primaryBlue
                          : AppColors.textGrey,
                      fontFamily: 'Cairo',
                      fontSize: 9.5,
                      fontWeight:
                          currentIndex == _homeIndex
                              ? FontWeight.w800
                              : FontWeight.w600,
                    ),
                    child: const Text('الرئيسية'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockNavigationItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockNavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Center(
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 270),
              curve: Curves.easeOutCubic,
              height: 50,
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 7,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 5 : 3,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.primaryBlue
                              .withOpacity(0.14),
                          AppColors.primaryBlue
                              .withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                          .withOpacity(0.10)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 190),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.76,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isSelected
                          ? selectedIcon
                          : icon,
                      key: ValueKey<bool>(isSelected),
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textGrey,
                      size: isSelected ? 22 : 21,
                    ),
                  ),
                  AnimatedSize(
                    duration:
                        const Duration(milliseconds: 230),
                    curve: Curves.easeOutCubic,
                    child: isSelected
                        ? Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 1,
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:
                                    AppColors.primaryBlue,
                                fontFamily: 'Cairo',
                                fontSize: 8.5,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeOrbButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _HomeOrbButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'الرئيسية',
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        tween: Tween<double>(
          begin: 1,
          end: isSelected ? 1.07 : 1,
        ),
        builder: (
          BuildContext context,
          double scale,
          Widget? child,
        ) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(
                  isSelected ? 0.08 : 0.03,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 61 : 57,
                  height: isSelected ? 61 : 57,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryBlue
                                  .withOpacity(0.88),
                              AppColors.primaryBlue
                                  .withOpacity(0.68),
                            ],
                          ),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue
                            .withOpacity(
                          isSelected ? 0.34 : 0.18,
                        ),
                        blurRadius:
                            isSelected ? 22 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 190),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isSelected
                          ? Icons.home
                          : Icons.home_outlined,
                      key: ValueKey<bool>(isSelected),
                      color: Colors.white,
                      size: isSelected ? 29 : 27,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingDockPainter extends CustomPainter {
  final bool isHomeSelected;

  const _FloatingDockPainter({
    required this.isHomeSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = size.width / 2;
    const radius = 27.0;
    const notchHalfWidth = 42.0;

    path.moveTo(radius, 0);
    path.lineTo(center - notchHalfWidth, 0);

    path.cubicTo(
      center - 33,
      0,
      center - 32,
      15,
      center - 21,
      23,
    );

    path.cubicTo(
      center - 11,
      31,
      center + 11,
      31,
      center + 21,
      23,
    );

    path.cubicTo(
      center + 32,
      15,
      center + 33,
      0,
      center + notchHalfWidth,
      0,
    );

    path.lineTo(size.width - radius, 0);

    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      radius,
    );

    path.lineTo(
      size.width,
      size.height - radius,
    );

    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    path.lineTo(radius, size.height);

    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - radius,
    );

    path.lineTo(0, radius);

    path.quadraticBezierTo(
      0,
      0,
      radius,
      0,
    );

    path.close();

    canvas.drawShadow(
      path,
      AppColors.primaryBlue.withOpacity(
        isHomeSelected ? 0.18 : 0.13,
      ),
      isHomeSelected ? 18 : 14,
      false,
    );

    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF7FBFF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, backgroundPaint);

    final borderPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(
    covariant _FloatingDockPainter oldDelegate,
  ) {
    return oldDelegate.isHomeSelected !=
        isHomeSelected;
  }
}