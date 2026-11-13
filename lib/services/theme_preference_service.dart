// Persistencia de la preferencia de tema (claro u oscuro).
//
// Usa SharedPreferences para recordar, entre sesiones, si el usuario eligió
// el modo oscuro o el modo claro.
import 'package:shared_preferences/shared_preferences.dart';

/// Lee y guarda en el dispositivo si el usuario prefiere el modo oscuro.
class ThemePreferenceService {
  static const _key = 'task-theme';

  /// Devuelve true si el usuario tenía activado el modo oscuro.
  Future<bool> loadDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key) == 'dark';
  }

  /// Guarda la preferencia de tema; lanza si el almacenamiento falla.
  Future<void> saveDarkMode(bool darkMode) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _key,
      darkMode ? 'dark' : 'light',
    );
    if (!saved) {
      throw StateError('No se pudo guardar la preferencia del tema.');
    }
  }
}
