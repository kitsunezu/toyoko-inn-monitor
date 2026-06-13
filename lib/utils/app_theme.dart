import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dashDarkPrimary,
      brightness: Brightness.dark,
      primary: AppColors.dashDarkPrimary,
      secondary: AppColors.brandRed,
      surface: AppColors.dashDarkPanel,
      error: AppColors.dashDanger,
    ),
    scaffoldBackgroundColor: AppColors.dashDarkBg,
    cardColor: AppColors.dashDarkPanel,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dashDarkBg,
      elevation: 0,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.dashDarkSidebar,
      selectedIconTheme: IconThemeData(color: AppColors.dashDarkPrimary),
      selectedLabelTextStyle: TextStyle(color: AppColors.dashDarkPrimary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.dashDarkBorder),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.dashDarkTextPrimary,
      displayColor: AppColors.dashDarkTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.dashDarkPanel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.dashDarkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dashDarkPanelRaised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dashDarkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dashDarkBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.dashDarkTextMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.brand
            : AppColors.dashDarkPanelRaised,
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
      primary: AppColors.brand,
      secondary: AppColors.brandRed,
      surface: AppColors.dashPanel,
      error: AppColors.dashDanger,
    ),
    scaffoldBackgroundColor: AppColors.dashBg,
    cardColor: AppColors.dashPanel,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dashSidebar,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.dashBorder),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.dashSidebar,
      selectedIconTheme: IconThemeData(color: AppColors.dashPrimary),
      selectedLabelTextStyle: TextStyle(color: AppColors.dashPrimary),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
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
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.brand
            : AppColors.dashPanelRaised,
      ),
    ),
  );
}
