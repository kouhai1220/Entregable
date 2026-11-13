// Punto de entrada de la aplicación "MisTareas".
//
// Este archivo se encarga de:
// - Inicializar Flutter y arrancar Firebase con las opciones de la plataforma
//   actual (definidas en firebase_options.dart).
// - Crear el servicio de datos (FirebaseService) y compartirlo con toda la app.
// - Configurar MaterialApp con los temas claro y oscuro, y aplicar la
//   preferencia de tema que el usuario dejó guardada.
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/theme_preference_service.dart';
import 'theme/app_theme.dart';
import 'views/app_shell.dart';

/// Función principal de la aplicación.
///
/// Inicializa Firebase sin bloquear el arranque (si falla, la app sigue
/// funcionando y el error se muestra más tarde), crea el servicio de datos y
/// lanza [TaskApp] inyectándolo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .then<void>(
            (_) {},
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('No se pudo iniciar Firebase: $error\n$stackTrace');
              throw error;
            },
          );
  firebaseReady.then<void>(
    (_) {},
    onError: (Object error, StackTrace stackTrace) {
      debugPrint('Firebase no está disponible: $error');
    },
  );
  final firebaseService = FirebaseServiceImpl(firebaseReady: firebaseReady);
  runApp(TaskApp(firebaseService: firebaseService));
}

/// Aplicación raíz de "MisTareas".
///
/// Configura MaterialApp con los temas claro/oscuro y se encarga de cargar,
/// guardar y aplicar la preferencia de tema elegida por el usuario.
class TaskApp extends StatefulWidget {
  const TaskApp({
    required this.firebaseService,
    this.initialDarkMode = false,
    super.key,
  });

  final FirebaseService firebaseService;
  final bool initialDarkMode;

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  final ThemePreferenceService _themePreferences = ThemePreferenceService();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late bool _darkMode = widget.initialDarkMode;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  /// Carga desde el almacenamiento local la preferencia de tema guardada.
  Future<void> _loadThemePreference() async {
    try {
      final darkMode = await _themePreferences.loadDarkMode();
      if (mounted) setState(() => _darkMode = darkMode);
    } on Object catch (error, stackTrace) {
      debugPrint(
        'No se pudo cargar la preferencia del tema: $error\n$stackTrace',
      );
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _messengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('No se pudo cargar el tema guardado.'),
            ),
          );
        });
      }
    }
  }

  /// Cambia el tema, lo aplica de inmediato y lo guarda para la próxima vez.
  Future<void> _toggleTheme() async {
    final nextDarkMode = !_darkMode;
    setState(() => _darkMode = nextDarkMode);
    await _themePreferences.saveDarkMode(nextDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      title: 'MisTareas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppShell(
        darkMode: _darkMode,
        onToggleTheme: _toggleTheme,
        firebaseService: widget.firebaseService,
      ),
    );
  }
}
