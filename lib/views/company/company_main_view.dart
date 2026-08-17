import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/company_main_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/core/widgets/company/company_bottom_navigation_bar.dart';
import 'package:jisr_platform/core/widgets/company/company_drawer.dart';
import 'package:jisr_platform/core/widgets/company/jisr_animated_logo.dart';
import 'package:jisr_platform/views/company/conversations/company_conversations_view.dart';
import 'package:jisr_platform/views/company/home/company_home_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunities_view.dart';
import 'package:jisr_platform/views/company/profile/company_profile_view.dart';

class CompanyMainView extends GetView<CompanyMainController> {
  const CompanyMainView({super.key});

  static const List<Widget> _pages = <Widget>[
    _CompanySearchPlaceholder(),
    CompanyOpportunitiesView(),
    CompanyHomeView(),
    CompanyConversationsView(),
    CompanyProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const CompanyDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.32),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leadingWidth: 92,
leading: Builder(
  builder: (scaffoldContext) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 6,
        end: 2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Material(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () {
                  Scaffold.of(scaffoldContext).openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 38,
            height: 38,
            child: Material(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () {
                  // منطق الإشعارات لاحقًا.
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
),
          title: const Text(
            'جسور',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: Center(
                child: JisrAnimatedLogo(size: 38),
              ),
            ),
          ],
        ),
        body: Obx(() {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
  final velocity = details.primaryVelocity ?? 0;

  if (velocity.abs() < 280) {
    return;
  }

  if (velocity < 0) {
    // سحب باتجاه اليسار
    controller.openPreviousTab();
  } else {
    // سحب باتجاه اليمين
    controller.openNextTab();
  }
},
            child: _CompanyPageSwitcher(
              index: controller.selectedIndex.value,
              pages: _pages,
            ),
          );
        }),
        bottomNavigationBar: Obx(
          () => CompanyBottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}

class _CompanyPageSwitcher extends StatefulWidget {
  final int index;
  final List<Widget> pages;

  const _CompanyPageSwitcher({
    required this.index,
    required this.pages,
  });

  @override
  State<_CompanyPageSwitcher> createState() {
    return _CompanyPageSwitcherState();
  }
}

class _CompanyPageSwitcherState extends State<_CompanyPageSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late int _currentIndex;
  late int _previousIndex;

  double _direction = 1;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.index;
    _previousIndex = widget.index;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(
    covariant _CompanyPageSwitcher oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.index == _currentIndex) {
      return;
    }

    _previousIndex = _currentIndex;
    _direction = widget.index > _currentIndex ? -1 : 1;
    _currentIndex = widget.index;

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(
            _animationController.value,
          );

          return Stack(
            fit: StackFit.expand,
            children: List<Widget>.generate(
              widget.pages.length,
              (index) {
                final isCurrent = index == _currentIndex;

                final isPrevious =
                    index == _previousIndex &&
                    _animationController.value < 1;

                final isVisible = isCurrent || isPrevious;

                double opacity = 0;
                double horizontalOffset = 0;

                if (isCurrent) {
                  opacity = progress;
                  horizontalOffset =
                      (1 - progress) * 22 * _direction;
                } else if (isPrevious) {
                  opacity = 1 - progress;
                  horizontalOffset =
                      progress * -10 * _direction;
                }

                return Offstage(
                  offstage: !isVisible,
                  child: IgnorePointer(
                    ignoring:
                        !isCurrent ||
                        _animationController.value < 1,
                    child: TickerMode(
                      enabled:
                          isCurrent &&
                          _animationController.value == 1,
                      child: Opacity(
                        opacity: opacity
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        child: Transform.translate(
                          offset: Offset(
                            horizontalOffset,
                            0,
                          ),
                          child: RepaintBoundary(
                            child: widget.pages[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CompanySearchPlaceholder extends StatelessWidget {
  const _CompanySearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          24,
          18,
          120,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.07),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryBlue,
                  size: 38,
                ),
                SizedBox(height: 14),
                Text(
                  'البحث عن الطلاب',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'سيتم قريبًا تفعيل البحث باسم الطالب أو المهارة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
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