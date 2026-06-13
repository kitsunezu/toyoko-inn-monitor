import 'package:flutter/material.dart';

/// 東橫 INN 品牌色彩系統
class AppColors {
  AppColors._();

  // 品牌色
  static const Color brand = Color(0xFF00489D);
  static const Color primary = Color(0xFF00489D);
  static const Color brandRed = Color(0xFFD71920);
  static const Color brandGold = Color(0xFFC78318);

  // 狀態色
  static const Color available = Color(0xFF007C5F); // 有空房
  static const Color match = Color(0xFFD71920); // 符合目標
  static const Color error = Color(0xFFB3261E); // 錯誤
  static const Color warning = Color(0xFFC78318); // 警告（房間不足）
  static const Color maintenance = Color(0xFF5D7FA7); // 維護中
  static const Color noRoom = Color(0xFF8A94A3); // 無空房

  // 背景色
  static const Color darkBg = Color(0xFF111820);
  static const Color darkSurface = Color(0xFF172434);
  static const Color darkCard = Color(0xFF203247);

  // Dashboard redesign palette.
  static const Color dashBg = Color(0xFFF6F8FB);
  static const Color dashSidebar = Color(0xFFFFFFFF);
  static const Color dashPanel = Color(0xFFFFFFFF);
  static const Color dashPanelRaised = Color(0xFFEEF4FA);
  static const Color dashBorder = Color(0xFFD5E2EF);
  static const Color dashPrimary = brand;
  static const Color dashSuccess = available;
  static const Color dashWarning = warning;
  static const Color dashDanger = brandRed;

  // 文字色
  static const Color textPrimary = Color(0xFF17243A);
  static const Color textSecondary = Color(0xFF46566B);
  static const Color textMuted = Color(0xFF768395);
  static const Color dashTextPrimary = textPrimary;
  static const Color dashTextSecondary = textSecondary;
  static const Color dashTextMuted = textMuted;

  static const Color dashDarkBg = Color(0xFF111820);
  static const Color dashDarkSidebar = Color(0xFF152235);
  static const Color dashDarkPanel = Color(0xFF192A3F);
  static const Color dashDarkPanelRaised = Color(0xFF20354E);
  static const Color dashDarkBorder = Color(0xFF31475F);
  static const Color dashDarkPrimary = Color(0xFF66A7E8);
  static const Color dashDarkTextPrimary = Color(0xFFF4F8FC);
  static const Color dashDarkTextSecondary = Color(0xFFC9D5E2);
  static const Color dashDarkTextMuted = Color(0xFF8FA1B5);
}
