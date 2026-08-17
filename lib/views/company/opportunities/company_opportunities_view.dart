import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/opportunities/company_opportunities_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'package:jisr_platform/models/company/opportunities/company_opportunity_feed_item.dart';

class CompanyOpportunitiesView extends GetView<CompanyOpportunitiesController> {
  const CompanyOpportunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Obx(() {
            final items = controller.visibleItems;

            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: controller.fetchItems,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _Header(onCreate: () => _showCreateSheet(context)),
                  const SizedBox(height: 20),
                  _SearchField(
                    onSearchChanged: controller.updateSearch,
                  ),
                  const SizedBox(height: 16),
                  _DisplayFilterPanel(
                    selectedType: controller.selectedType.value,
                    selectedStatus: controller.selectedStatus.value,
                    onTypeChanged: controller.selectType,
                    onStatusPressed: () => _showStatusSheet(context),
                  ),
                  if (controller.isLoading.value) ...[
                    const SizedBox(height: 14),
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        color: AppColors.primaryBlue,
                        backgroundColor: Color(0xFFE7EEF4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: _sectionTitle(controller.selectedType.value),
                    count: items.length,
                  ),
                  const SizedBox(height: 12),
                  if (controller.isLoading.value && items.isEmpty)
                    const _LoadingState()
                  else if (controller.errorMessage.value.isNotEmpty &&
                      items.isEmpty)
                    _PageState(
                      icon: Icons.cloud_off_rounded,
                      title: 'تعذّر تحميل الفرص',
                      message: controller.errorMessage.value,
                      actionLabel: 'إعادة المحاولة',
                      onAction: controller.fetchItems,
                    )
                  else if (items.isEmpty)
                    _PageState(
                      icon: Icons.work_outline_rounded,
                      title: 'لا توجد نتائج',
                      message: controller.searchQuery.value.trim().isNotEmpty
                          ? 'لا توجد نتيجة مطابقة لبحثك ضمن الفلتر المحدد.'
                          : 'جرّب اختيار نوع أو حالة أخرى، أو أنشئ فرصة جديدة.',
                    )
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OpportunityCard(
                          item: item,
                          onTap: () => controller.openItem(item),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  String _sectionTitle(CompanyOpportunityTypeFilter type) {
    switch (type) {
      case CompanyOpportunityTypeFilter.task:
        return 'المهام';
      case CompanyOpportunityTypeFilter.internship:
        return 'فرص التدريب';
      case CompanyOpportunityTypeFilter.job:
        return 'فرص العمل';
      case CompanyOpportunityTypeFilter.all:
        return 'جميع الفرص';
    }
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ماذا تريد أن تنشئ؟',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'اختر المسار المناسب، وسنجهّز لك النموذج المطلوب.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _CreateOption(
                  icon: Icons.task_alt_rounded,
                  title: 'مهمة تطبيقية',
                  subtitle: 'عمل تطبيقي محدد يستطيع الطلاب التقديم عليه',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.createTask();
                  },
                ),
                const SizedBox(height: 10),
                _CreateOption(
icon: Icons.work_outline_rounded,                  title: 'فرصة عمل أو تدريب',
                  subtitle: 'انشر وظيفة أو برنامج تدريب وحدّد نوعه داخل النموذج',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.createOpportunity();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    final statuses = List<CompanyOpportunityStatusFilter>.from(
      controller.availableStatuses,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final sheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.66;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: sheetHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'فلترة حسب الحالة',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'اختر حالة العناصر التي تريد عرضها',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: statuses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final status = statuses[index];
                          final selected =
                              controller.selectedStatus.value == status;

                          return Material(
                            color: selected
                                ? AppColors.primaryBlue.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: Text(
                                status.label,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primaryBlue
                                      : AppColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              trailing: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selected
                                    ? AppColors.primaryBlue
                                    : AppColors.textGrey.withOpacity(0.45),
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                controller.selectStatus(status);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreate;

  const _Header({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الفرص',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'تابع المهام وفرص التدريب والعمل',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onCreate,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const _SearchField({
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث بعنوان الفرصة أو موقعها...',
        hintStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textGrey,
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _DisplayFilterPanel extends StatelessWidget {
  final CompanyOpportunityTypeFilter selectedType;
  final CompanyOpportunityStatusFilter selectedStatus;
  final ValueChanged<CompanyOpportunityTypeFilter> onTypeChanged;
  final VoidCallback onStatusPressed;

  const _DisplayFilterPanel({
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatusFilter =
        selectedStatus != CompanyOpportunityStatusFilter.all;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: AppColors.primaryBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خيارات العرض',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'اختر النوع والحالة',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: hasStatusFilter
                    ? AppColors.primaryBlue
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onStatusPressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasStatusFilter
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlue.withOpacity(0.09),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: hasStatusFilter
                              ? Colors.white
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحالة',
                              style: TextStyle(
                                color: hasStatusFilter
                                    ? Colors.white70
                                    : AppColors.textGrey,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              selectedStatus.label,
                              style: TextStyle(
                                color: hasStatusFilter
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: hasStatusFilter
                              ? Colors.white
                              : AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TypeSelector(
            selectedType: selectedType,
            onChanged: onTypeChanged,
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final CompanyOpportunityTypeFilter selectedType;
  final ValueChanged<CompanyOpportunityTypeFilter> onChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
      ),
      child: Row(
        children: CompanyOpportunityTypeFilter.values.map((type) {
          final selected = selectedType == type;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: selected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    if (!selected) onChanged(type);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      _label(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(CompanyOpportunityTypeFilter type) {
    switch (type) {
      case CompanyOpportunityTypeFilter.all:
        return 'الكل';
      case CompanyOpportunityTypeFilter.task:
        return 'المهام';
      case CompanyOpportunityTypeFilter.internship:
        return 'التدريب';
      case CompanyOpportunityTypeFilter.job:
        return 'الوظائف';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final CompanyOpportunityFeedItem item;
  final VoidCallback onTap;

  const _OpportunityCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _kindIcon(item.kind),
                      color: AppColors.primaryBlue,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: _statusLabel(item.status),
                    status: item.status,
                  ),
                ],
              ),
              if (item.description.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: _kindIcon(item.kind),
                    label: _kindLabel(item.kind),
                  ),
                  if (item.meta.trim().isNotEmpty)
                    _InfoChip(
                      icon: item.kind == CompanyFeedKind.task
                          ? Icons.schedule_rounded
                          : Icons.location_on_outlined,
                      label: item.meta,
                    ),
                  _InfoChip(
                    icon: Icons.groups_2_outlined,
                    label: item.kind == CompanyFeedKind.task
                        ? 'السعة ${item.applicationsCount}'
                        : '${item.applicationsCount} متقدم',
                  ),
                  if (item.deadline != null)
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: _dateLabel(item.deadline!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _kindIcon(CompanyFeedKind kind) {
    switch (kind) {
      case CompanyFeedKind.task:
        return Icons.task_alt_rounded;
      case CompanyFeedKind.internship:
        return Icons.school_rounded;
      case CompanyFeedKind.job:
        return Icons.work_rounded;
    }
  }

  static String _kindLabel(CompanyFeedKind kind) {
    switch (kind) {
      case CompanyFeedKind.task:
        return 'مهمة';
      case CompanyFeedKind.internship:
        return 'تدريب';
      case CompanyFeedKind.job:
        return 'وظيفة';
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'published':
        return 'منشورة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'closed':
        return 'مغلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  static String _dateLabel(DateTime date) {
    return 'حتى ${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String status;

  const _StatusChip({required this.label, required this.status});

  Color get color {
    switch (status) {
      case 'draft':
        return AppColors.actionYellow;
      case 'published':
        return AppColors.primaryBlue;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGrey, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 54),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 42),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}
