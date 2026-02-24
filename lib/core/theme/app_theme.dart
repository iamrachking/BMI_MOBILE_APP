import 'package:flutter/material.dart';

/// Couleurs et thème de l'app.
/// Primaire: #2e4053 ; Background: #f9fafc
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF2E4053);
  static const Color background = Color(0xFFF9FAFC);

  /// Snackbar succès / info : couleur de l'app avec opacité pour différencier.
  static Color get snackbarSuccess => primary.withValues(alpha: 0.92);

  /// Snackbar avertissement (ex. stock épuisé) : couleur de l'app avec opacité.
  static Color get snackbarWarning => primary.withValues(alpha: 0.88);

  /// Snackbar erreur : rouge semi-transparent.
  static Color get snackbarError => Colors.red.withValues(alpha: 0.88);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: background,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
  );
}
