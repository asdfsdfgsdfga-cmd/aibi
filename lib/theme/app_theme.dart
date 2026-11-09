import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BIAIMX 设计系统 —— 深色金融主题
class AppColors {
  static const bg = Color(0xFF080B11);
  static const surface = Color(0xFF111724);
  static const surfaceAlt = Color(0xFF18202F);
  static const surfaceHigh = Color(0xFF1F2939);
  static const border = Color(0xFF232D40);
  static const primary = Color(0xFF4F8CFF);
  static const cyan = Color(0xFF22D3EE);
  static const up = Color(0xFF16C784);
  static const down = Color(0xFFEA3943);
  static const gold = Color(0xFFF5B544);
  static const text = Color(0xFFE9EEF7);
  static const subtext = Color(0xFF8A94A8);
  static const muted = Color(0xFF5B6478);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF5A5F);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F8CFF), Color(0xFF22D3EE)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7D06B), Color(0xFFE79B2F)],
  );
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
        error: AppColors.down,
        onPrimary: Colors.white,
        onSurface: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.subtext),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
    );
  }

  static const headline = TextStyle(
    color: AppColors.text,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );
  static const sectionTitle = TextStyle(
    color: AppColors.text,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    height: 1.6,
  );
  static const caption = TextStyle(
    color: AppColors.subtext,
    fontSize: 12,
    height: 1.4,
  );
}
