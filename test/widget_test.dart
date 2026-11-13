import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:entregable/main.dart';
import 'package:entregable/models/task_model.dart';
import 'package:entregable/models/user_profile.dart';
import 'package:entregable/services/firebase_service.dart';

class _FakeFirebaseService implements FirebaseService {
  _FakeFirebaseService({this.pendingRestore});

  final Future<UserProfile?>? pendingRestore;
  UserProfile? _profile;
  final List<TaskModel> _tasks = [
    const TaskModel(
      id: 1,
      title: 'Preparar presentación semanal',
      category: TaskCategory.trabajo,
      dueLabel: 'Hoy, 10:30',
      reminder: true,
      completed: false,
    ),
    const TaskModel(
      id: 2,
      title: 'Repasar notas de diseño',
      category: TaskCategory.estudio,
      dueLabel: 'Hoy, 18:00',
      reminder: true,
      completed: false,
    ),
    const TaskModel(
      id: 3,
      title: 'Comprar productos de casa',
      category: TaskCategory.personal,
      dueLabel: 'Mañana, 09:00',
      reminder: false,
      completed: false,
    ),
    const TaskModel(
      id: 4,
      title: 'Enviar informe mensual',
      category: TaskCategory.trabajo,
      dueLabel: 'Vie, 16:30',
      reminder: true,
      completed: true,
    ),
  ];

  @override
  String? get currentUserId => _profile == null ? null : 'test-user';

  @override
  UserProfile? get currentProfile => _profile;

  @override
  Future<UserProfile?> restoreSession() =>
      pendingRestore ?? Future.value(_profile);

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    _profile = UserProfile(name: 'Persona de prueba', email: email);
    return _profile!;
  }

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _profile = UserProfile(name: name, email: email);
    return _profile!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> signOut() async {
    _profile = null;
  }

  @override
  Stream<List<TaskModel>> watchTasks() => Stream.value(_tasks);

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    _tasks[index] = task;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> startApp(
    WidgetTester tester, {
    _FakeFirebaseService? service,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TaskApp(firebaseService: service ?? _FakeFirebaseService()),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> openDashboard(WidgetTester tester) async {
    await startApp(tester);
    await tester.tap(find.text('TOCA PARA CONTINUAR'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'persona@ejemplo.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'contrasena');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pumpAndSettle();
  }

  testWidgets('launches the app and continues to sign in', (tester) async {
    await startApp(tester);

    expect(find.text('MisTareas'), findsOneWidget);
    expect(find.text('Enfócate en lo que importa.'), findsNothing);
    await tester.tap(find.text('TOCA PARA CONTINUAR'));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido de nuevo!'), findsOneWidget);
  });

  testWidgets('shows the welcome screen while session restoration is pending', (
    tester,
  ) async {
    final restore = Completer<UserProfile?>();
    await startApp(
      tester,
      service: _FakeFirebaseService(pendingRestore: restore.future),
    );

    expect(find.text('TOCA PARA CONTINUAR'), findsOneWidget);
    await tester.tap(find.text('TOCA PARA CONTINUAR'));
    await tester.pump();

    expect(find.text('CONECTANDO...'), findsOneWidget);
    expect(find.text('¡Bienvenido de nuevo!'), findsNothing);

    restore.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('¡Bienvenido de nuevo!'), findsOneWidget);
  });

  testWidgets('sign in opens the task dashboard', (tester) async {
    await openDashboard(tester);

    expect(find.text('Mis Tareas'), findsOneWidget);
    expect(find.text('Viernes, 24 de mayo'), findsNothing);
    expect(find.text('Preparar presentación semanal'), findsOneWidget);
    expect(find.text('4 tareas'), findsOneWidget);
  });

  testWidgets('creates a task from the add task form', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('add-task-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-title-field')),
      'Revisar el diseño Flutter',
    );
    await tester.drag(
      find.byKey(const ValueKey('task-form-scroll')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-task')));
    await tester.pumpAndSettle();

    expect(find.text('Revisar el diseño Flutter'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsNothing);
  });

  testWidgets('filters tasks by search query', (tester) async {
    await openDashboard(tester);

    await tester.enterText(find.byType(TextField), 'mensual');
    await tester.pumpAndSettle();

    expect(find.text('Enviar informe mensual'), findsOneWidget);
    expect(find.text('Preparar presentación semanal'), findsNothing);
  });

  testWidgets('persists and applies the dark theme', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.byTooltip('Activar modo oscuro'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Mis Tareas'))).brightness,
      Brightness.dark,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('task-theme'), 'dark');
  });

  testWidgets('profile opens separately from the sign-out action', (
    tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('open-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Persona de prueba'), findsOneWidget);
    expect(find.text('persona@ejemplo.com'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-sign-out')), findsOneWidget);
    expect(find.text('Mis Tareas'), findsOneWidget);
  });

  testWidgets('profile details can be edited', (tester) async {
    await openDashboard(tester);
    await tester.tap(find.byKey(const ValueKey('open-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-profile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Ana García');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana García'), findsOneWidget);
    expect(find.text('persona@ejemplo.com'), findsOneWidget);
  });

  testWidgets('sign out requires confirmation and returns to sign in', (
    tester,
  ) async {
    await openDashboard(tester);
    await tester.tap(find.byKey(const ValueKey('open-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido de nuevo!'), findsOneWidget);
    expect(find.text('Mis Tareas'), findsNothing);
  });

  testWidgets('theme toggle responds on login and registration', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(find.text('TOCA PARA CONTINUAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Activar modo oscuro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('¡Bienvenido de nuevo!'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Activar modo claro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Crea tu cuenta'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('shows the password recovery dialog', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('TOCA PARA CONTINUAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.text('Recuperar contraseña'), findsOneWidget);
  });
}
