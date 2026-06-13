import 'package:flutter/material.dart';

/// 東橫 INN 品牌色彩系統
class AppColors {
  AppColors._();

  // 品牌色
  static const Color brand = Color(0xFF00489D);
  static const Color primary = Color(0xFF1A72D4);

  // 狀態色
  static const Color available = Color(0xFF5DC89A); // 有空房
  static const Color match = Color(0xFFE8C870); // 符合目標
  static const Color error = Color(0xFFE05C6E); // 錯誤
  static const Color warning = Color(0xFFD8A27E); // 警告（房間不足）
  static const Color maintenance = Color(0xFF8FA8E0); // 維護中
  static const Color noRoom = Color(0xFF888888); // 無空房

  // 背景色
  static const Color darkBg = Color(0xFF1E1E2E);
  static const Color darkSurface = Color(0xFF313244);
  static const Color darkCard = Color(0xFF45475A);

  // Dashboard redesign palette.
  static const Color dashBg = Color(0xFF0F141B);
  static const Color dashSidebar = Color(0xFF121923);
  static const Color dashPanel = Color(0xFF18212D);
  static const Color dashPanelRaised = Color(0xFF202B38);
  static const Color dashBorder = Color(0xFF2C3948);
  static const Color dashPrimary = Color(0xFF4DA3FF);
  static const Color dashSuccess = Color(0xFF35D07F);
  static const Color dashWarning = Color(0xFFF2C94C);
  static const Color dashDanger = Color(0xFFFF5C68);

  // 文字色
  static const Color textPrimary = Color(0xFFCDD6F4);
  static const Color textSecondary = Color(0xFFBAC2DE);
  static const Color textMuted = Color(0xFF585B70);
  static const Color dashTextPrimary = Color(0xFFE6EDF3);
  static const Color dashTextSecondary = Color(0xFF9AA8B6);
  static const Color dashTextMuted = Color(0xFF647282);
}
