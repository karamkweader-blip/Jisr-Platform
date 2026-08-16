part of '../company_opportunity_form_view.dart';

class _SubmitBar extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SubmitBar({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 11, 18, 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: const Border(
            top: BorderSide(color: Color(0xFFE4EBF1)),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163047).withOpacity(0.07),
              blurRadius: 17,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: const Color(0xFFD5DFE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 20),
            label: Text(
              isLoading ? 'جارٍ الحفظ...' : label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
