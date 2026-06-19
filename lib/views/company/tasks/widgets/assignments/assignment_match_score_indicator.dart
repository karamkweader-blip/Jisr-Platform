import 'package:flutter/material.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';

class AssignmentMatchScoreIndicator extends StatelessWidget {
  final double score;
  final bool compact;

  const AssignmentMatchScoreIndicator({
    super.key,
    required this.score,
    this.compact = false,
  });

  double get _safeScore => score.clamp(0, 100).toDouble();

  Color get _scoreColor {
    if (_safeScore < 40) {
      return Colors.red;
    }

    if (_safeScore < 70) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String get _scoreLabel {
    if (_safeScore < 40) {
      return 'توافق منخفض';
    }

    if (_safeScore < 70) {
      return 'توافق متوسط';
    }

    return 'توافق مرتفع';
  }

  String get _scoreDescription {
    if (_safeScore == 0) {
      return 'لا توجد مهارات متطابقة بين ملف الطالب ومتطلبات المهمة.';
    }

    if (_safeScore < 40) {
      return 'التوافق الحالي منخفض ويحتاج الطالب إلى تطوير مهارات أساسية.';
    }

    if (_safeScore < 70) {
      return 'يوجد توافق جزئي بين مهارات الطالب ومتطلبات المهمة.';
    }

    return 'يمتلك الطالب توافقاً جيداً مع متطلبات المهمة.';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Tooltip(
        message: 'توافق المهارات: ${_safeScore.round()}%',
        child: _ScoreCircle(
          score: _safeScore,
          color: _scoreColor,
          size: 46,
          strokeWidth: 4.5,
          textSize: 11,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _scoreColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _scoreColor.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          _ScoreCircle(
            score: _safeScore,
            color: _scoreColor,
            size: 96,
            strokeWidth: 9,
            textSize: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نسبة توافق المهارات',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _scoreLabel,
                  style: TextStyle(
                    color: _scoreColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _scoreDescription,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
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

class _ScoreCircle extends StatelessWidget {
  final double score;
  final Color color;
  final double size;
  final double strokeWidth;
  final double textSize;

  const _ScoreCircle({
    required this.score,
    required this.color,
    required this.size,
    required this.strokeWidth,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: color.withOpacity(0.14),
            ),
          ),
          Text(
            '${score.round()}%',
            style: TextStyle(
              color: color,
              fontSize: textSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}