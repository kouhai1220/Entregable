// Contenedor principal (navegador) de la aplicación.
//
// Es el "cerebro" de la navegación: guarda en qué pantalla estamos
// (AppScreen), el perfil del usuario y el stream de tareas de Firestore, y
// decide qué vista construir. También concentra las acciones contra
// Firebase (iniciar sesión, registrarse, guardar/actualizar tareas, cerrar
// sesión) y delega la interfaz en las pantallas de la carpeta views/.
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../services/firebase_service.dart';
import '../widgets/profile_sheet.dart';
import 'add_task_screen.dart';
import 'auth_screens.dart';
import 'empty_state_screen.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

/// Navegador raíz: mantiene el estado de sesión y decide qué pantalla mostrar.
class AppShell extends StatefulWidget {
  const AppShell({
    required this.darkMode,
    required this.onToggleTheme,
    required this.firebaseService,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final FirebaseService firebaseService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen _screen = AppScreen.splash;
  UserProfile? _profile;
  Stream<List<TaskModel>>? _tasksStream;
  int _taskStreamKey = 0;
  bool _isContinuing = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.firebaseService.currentProfile;
    if (_profile != null) {
      _tasksStream = widget.firebaseService.watchTasks();
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(firebaseErrorMessage(error))));
  }

  /// Restaura la sesión guardada al entrar desde el splash y decide si
  /// mostrar el login o el panel de tareas.
  Future<void> _continueFromSplash() async {
    if (_isContinuing) return;
    setState(() => _isContinuing = true);
    try {
      final profile = await widget.firebaseService.restoreSession();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        if (profile != null) {
          _tasksStream = widget.firebaseService.watchTasks();
        }
        _screen = profile == null ? AppScreen.login : AppScreen.tasks;
        _isContinuing = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _screen = AppScreen.login;
        _isContinuing = false;
      });
      _showError(error);
    }
  }

  /// Inicia sesión, carga el stream de tareas y entra al panel.
  Future<void> _signIn(String email, String password) async {
    try {
      final profile = await widget.firebaseService.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _tasksStream = widget.firebaseService.watchTasks();
        _screen = AppScreen.tasks;
      });
    } on Object catch (error) {
      _showError(error);
    }
  }

  /// Registra un usuario nuevo, carga sus tareas y entra al panel.
  Future<void> _register(String name, String email, String password) async {
    try {
      final profile = await widget.firebaseService.register(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _tasksStream = widget.firebaseService.watchTasks();
        _screen = AppScreen.tasks;
      });
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _sendPasswordReset(String email) async {
    try {
      await widget.firebaseService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos un enlace para restablecer tu contraseña.'),
        ),
      );
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.firebaseService.signOut();
      if (!mounted) return;
      setState(() {
        _profile = null;
        _tasksStream = null;
        _screen = AppScreen.login;
      });
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    await widget.firebaseService.updateProfile(profile);
    if (mounted) setState(() => _profile = profile);
  }

  /// Abre la hoja inferior con la información y acciones del perfil.
  Future<void> _showProfile() async {
    final profile = _profile;
    if (profile == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProfileSheet(
        profile: profile,
        onSave: _saveProfile,
        onSignOut: _signOut,
      ),
    );
  }

  /// Guarda una tarea nueva y vuelve al panel con la lista actualizada.
  Future<void> _saveTask(TaskModel task) async {
    setState(() {
      _tasksStream = widget.firebaseService.watchTasks();
      _screen = AppScreen.tasks;
    });
    try {
      await widget.firebaseService.addTask(task);
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _updateTask(TaskModel task) async {
    try {
      await widget.firebaseService.updateTask(task);
    } on Object catch (error) {
      _showError(error);
    }
  }

  Widget _buildTaskScreen() {
    final profile = _profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<List<TaskModel>>(
      key: ValueKey(_taskStreamKey),
      stream: _tasksStream ??= widget.firebaseService.watchTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    firebaseErrorMessage(snapshot.error!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() {
                      _tasksStream = widget.firebaseService.watchTasks();
                      _taskStreamKey++;
                    }),
                    child: const Text('Volver a intentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snapshot.data!;
        if (tasks.isEmpty) {
          return _buildEmptyScreen(profile);
        }
        return HomeScreen(
          key: const ValueKey(AppScreen.tasks),
          tasks: tasks,
          darkMode: widget.darkMode,
          onToggleTheme: widget.onToggleTheme,
          profileName: profile.name,
          onOpenProfile: _showProfile,
          onAdd: () => setState(() => _screen = AppScreen.form),
          onToggleTask: (id) {
            final task = tasks.firstWhere((task) => task.id == id);
            _updateTask(task.copyWith(completed: !task.completed));
          },
          onToggleReminder: (id) {
            final task = tasks.firstWhere((task) => task.id == id);
            _updateTask(task.copyWith(reminder: !task.reminder));
          },
          onShowEmpty: () => setState(() => _screen = AppScreen.empty),
        );
      },
    );
  }

  Widget _buildEmptyScreen(UserProfile profile) {
    return EmptyStateScreen(
      key: const ValueKey(AppScreen.empty),
      darkMode: widget.darkMode,
      onToggleTheme: widget.onToggleTheme,
      profileName: profile.name,
      onOpenProfile: _showProfile,
      onAdd: () => setState(() => _screen = AppScreen.form),
      onBack: () => setState(() {
        _tasksStream = widget.firebaseService.watchTasks();
        _screen = AppScreen.tasks;
      }),
    );
  }

  /// Construye la pantalla actual según el valor de `_screen`.
  Widget _buildScreen() {
    return switch (_screen) {
      AppScreen.splash => SplashScreen(
        key: const ValueKey(AppScreen.splash),
        onContinue: _continueFromSplash,
        isLoading: _isContinuing,
      ),
      AppScreen.login => LoginScreen(
        key: const ValueKey(AppScreen.login),
        darkMode: widget.darkMode,
        onToggleTheme: widget.onToggleTheme,
        onLogin: _signIn,
        onPasswordReset: _sendPasswordReset,
        onRegister: () => setState(() => _screen = AppScreen.register),
      ),
      AppScreen.register => RegisterScreen(
        key: const ValueKey(AppScreen.register),
        darkMode: widget.darkMode,
        onToggleTheme: widget.onToggleTheme,
        onRegister: _register,
        onLogin: () => setState(() => _screen = AppScreen.login),
      ),
      AppScreen.tasks => _buildTaskScreen(),
      AppScreen.form => AddTaskScreen(
        key: const ValueKey(AppScreen.form),
        darkMode: widget.darkMode,
        onToggleTheme: widget.onToggleTheme,
        onBack: () => setState(() => _screen = AppScreen.tasks),
        onSave: _saveTask,
      ),
      AppScreen.empty =>
        _profile == null
            ? const Center(child: CircularProgressIndicator())
            : _buildEmptyScreen(_profile!),
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _buildScreen());
}
