import 'package:flutter/material.dart';

enum ChatbotMode {
  platformHelp('platform_help', 'مساعدة المنصة', 'اسأل عن استخدام منصة جسر', Icons.help_outline_rounded),
  skillsMarketAnalysis('skills_market_analysis', 'مهاراتي وسوق العمل', 'حلّل مهاراتك وفجواتك وأولوية التعلّم', Icons.insights_rounded),
  opportunityMatching('opportunity_matching', 'فرص مناسبة لي', 'اكتشف الفرص الأقرب إلى ملفك', Icons.work_outline_rounded);

  const ChatbotMode(this.apiValue, this.arabicLabel, this.description, this.icon);

  final String apiValue;
  final String arabicLabel;
  final String description;
  final IconData icon;

  static ChatbotMode fromApiValue(String value) {
    return ChatbotMode.values.firstWhere(
      (mode) => mode.apiValue == value,
      orElse: () => ChatbotMode.platformHelp,
    );
  }
}
