import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dashPrimary,
      brightness: Brightness.dark,
      primary: AppColors.dashPrimary,
      surface: AppColors.dashPanel,
      error: AppColors.dashDanger,
    ),
    scaffoldBackgroundColor: AppColors.dashBg,
    cardColor: AppColors.dashPanel,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dashBg,
      elevation: 0,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.dashSidebar,
      selectedIconTheme: IconThemeData(color: AppColors.dashPrimary),
      selectedLabelTextStyle: TextStyle(color: AppColors.dashPrimary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.dashBorder),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.dashTextPrimary,
      displayColor: AppColors.dashTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.dashPanel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.dashBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dashPanelRaised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dashBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dashBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dashPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.dashTextMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.dashPrimary
            : AppColors.dashPanelRaised,
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}
