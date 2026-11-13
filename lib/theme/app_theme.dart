// Definición del tema visual de la aplicación.
//
// Centraliza la paleta de colores (color de acento y sus variantes) y los
// ThemeData de modo claro y oscuro que utiliza MaterialApp.
import 'package:flutter/material.dart';

/// Tema de la app: colores base y los [ThemeData] de modo claro y oscuro.
class AppTheme {
  /// Color principal (violeta) usado en toda la interfaz.
  static const accent = Color(0xFF5146E5);

  /// Variante más oscura del color principal, para botones y degradados.
  static const accentDeep = Color(0xFF4338CA);

  /// Tema de modo claro.
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF1F3F9),
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      surface: Color(0xFFFFFFFF),
      brightness: Brightness.light,
    ),
    fontFamily: 'Manrope',
  );

  /// Tema de modo oscuro.
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0D0E15),
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: Color(0xFF8A83FF),
      surface: Color(0xFF171927),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Manrope',
  );
}
