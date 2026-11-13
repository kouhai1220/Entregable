// Modelo del perfil del usuario que usa la aplicación.
//
// Guarda el nombre y el correo con los que se identifica al usuario en la
// cabecera y en la hoja de perfil, y sabe calcular sus iniciales para el avatar.

/// Datos básicos del usuario autenticado.
class UserProfile {
  const UserProfile({required this.name, required this.email});

  final String name;
  final String email;

  /// Iniciales del nombre (hasta 2 letras) para el avatar.
  /// Devuelve 'U' si el nombre está vacío.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return letters.isEmpty ? 'U' : letters;
  }
}
