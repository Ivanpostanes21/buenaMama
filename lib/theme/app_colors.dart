import 'package:flutter/material.dart';

/// Central color palette for the app, built around the BuenaMama lime-green
/// brand (#32CD32). Lime green is used as a deliberate ~20% accent; white space
/// and near-white surfaces dominate.
class AppColors {
  AppColors._();

  /// Primary accent — lime green.
  static const Color primaryGreen = Color(0xFF32CD32);

  /// Darker shade for hover / pressed states.
  static const Color primaryDark = Color(0xFF28A428);

  /// Slightly brighter stop used at the bottom of the button gradient.
  static const Color primaryButtonEnd = Color(0xFF2DB82D);

  /// 10% lime tint for subtle backgrounds (icon container, focused field fill).
  static Color get primaryTint => primaryGreen.withValues(alpha: 0.10);

  // Text.
  static const Color heading = Color(0xFF1E2A1E); // dark charcoal
  static const Color muted = Color(0xFF6B7A6B); // gray hints / secondary

  // Surfaces.
  static const Color bgBase = Color(0xFFF7FAF7); // very light off-white
  static const Color bgGradientStart = Color(0xFFFFFFFF);
  static const Color bgGradientEnd = Color(0xFFEDF6EA); // faint green tint
  static const Color fieldFill = Color(0xFFF2F5F2);

  // Sidebar (dark charcoal green).
  static const Color sidebar = Color(0xFF1E2A1E);
  static const Color sidebarElevated = Color(0xFF263326);
  static const Color sidebarMuted = Color(0xFF8A9A8A);

  // App content background.
  static const Color canvas = Color(0xFFF4F7F3);
  static const Color cardBorder = Color(0xFFEAEFE8);

  // Errors stay red for clear contrast against the green theme.
  static const Color error = Color(0xFFE53935);

  /// Button gradient: lime → slightly brighter lime.
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryGreen, primaryButtonEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Brighter variant used while the button is hovered.
  static const LinearGradient buttonGradientHover = LinearGradient(
    colors: [Color(0xFF44DE44), primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Logo tile gradient: lime → darker lime.
  static const LinearGradient logoGradient = LinearGradient(
    colors: [primaryGreen, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
