
// Capa de acceso a datos basada en Firebase.
//
// Este archivo contiene:
// - FirebaseService: la interfaz (contrato) que usan las vistas para
//   autenticar usuarios y leer/escribir tareas. Al ser una interfaz, la
//   interfaz gráfica no depende directamente de Firebase y es más fácil de probar.
// - FirebaseServiceImpl: la implementación real usando Firebase Authentication
//   (login, registro, recuperar contraseña, sesión) y Cloud Firestore
//   (documento del usuario y su subcolección de tareas).
// - firebaseErrorMessage: traduce los errores de Firebase a mensajes en
//   español listos para mostrar al usuario.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';
import '../models/user_profile.dart';

/// Contrato de acceso a datos que usa la interfaz gráfica.
///
/// Agrupa las operaciones de autenticación y de gestión de tareas, de modo que
/// las vistas no dependan directamente de Firebase (y sea posible sustituirlo,
/// por ejemplo en las pruebas).
abstract interface class FirebaseService {
  UserProfile? get currentProfile;
  String? get currentUserId;

  Future<UserProfile?> restoreSession();

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile(UserProfile profile);
  Future<void> signOut();
  Stream<List<TaskModel>> watchTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
}

/// Implementación real de [FirebaseService] con Firebase Authentication y
/// Cloud Firestore. Los parámetros opcionales permiten inyectar instancias
/// falsas en las pruebas.
class FirebaseServiceImpl implements FirebaseService {
  FirebaseServiceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Future<void>? firebaseReady,
  }) : _authOverride = auth,
       _firestoreOverride = firestore,
       _firebaseReady = firebaseReady ?? Future<void>.value();

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;
  final Future<void> _firebaseReady;
  User? _currentUser;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('Inicia sesión para acceder a tu perfil.');
    }
    return _users.doc(uid);
  }

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      _userDocument.collection('tasks');

  @override
  String? get currentUserId => _currentUser?.uid;

  @override
  UserProfile? get currentProfile {
    final user = _currentUser;
    return user == null ? null : _profileFromUser(user);
  }

  @override
  Future<UserProfile?> restoreSession() async {
    await _firebaseReady;
    _currentUser = _auth.currentUser;
    return currentProfile;
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseReady;
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase no devolvió el usuario autenticado.');
    }
    _currentUser = user;
    return _profileFromUser(user);
  }

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _firebaseReady;
    final normalizedName = name.trim();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase no devolvió el usuario recién creado.');
    }
    _currentUser = user;
    await Future.wait([
      user.updateDisplayName(normalizedName),
      _writeUserDocument(user, normalizedName),
    ]);
    return UserProfile(name: normalizedName, email: user.email ?? '');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseReady;
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _firebaseReady;
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Inicia sesión para editar tu perfil.');
    }
    final name = profile.name.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(
        profile.name,
        'name',
        'El nombre es obligatorio.',
      );
    }
    await user.updateDisplayName(name);
    await _userDocument.set(
      {
        'name': name,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseReady;
    await _auth.signOut();
    _currentUser = null;
  }

  @override
  /// Escucha en tiempo real las tareas del usuario en Firestore y las
  /// devuelve ordenadas por id de forma descendente (las más nuevas primero).
  Stream<List<TaskModel>> watchTasks() {
    return _taskCollection.snapshots().map((snapshot) {
      final tasks = snapshot.docs
          .map((document) {
            final id = int.tryParse(document.id);
            if (id == null) {
              throw FormatException(
                'El documento de tarea ${document.id} tiene un ID inválido.',
              );
            }
            return TaskModel.fromMap({...document.data(), 'id': id});
          })
          .toList();
      tasks.sort((a, b) => b.id.compareTo(a.id));
      return tasks;
    });
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _taskCollection.doc(task.id.toString()).set({
      ...task.toMap(),
      'ownerId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id.toString()).update({
      ...task.toMap(),
      'ownerId': currentUserId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _writeUserDocument(User user, String name) {
    return _userDocument.set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  UserProfile _profileFromUser(User user) => UserProfile(
    name: user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : _nameFromEmail(user.email),
    email: user.email ?? '',
  );

  /// Deriva un nombre legible a partir del correo cuando no hay displayName.
  String _nameFromEmail(String? email) {
    final name = email?.split('@').first.trim();
    if (name == null || name.isEmpty) return 'Usuario';
    return name.replaceAll(RegExp(r'[._-]+'), ' ');
  }
}

/// Convierte un error (normalmente de Firebase o de una validación) en un
/// mensaje claro en español para mostrar al usuario.
String firebaseErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'El correo electrónico no tiene un formato válido.',
      'user-disabled' => 'Esta cuenta está deshabilitada.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'El correo o la contraseña no son correctos.',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
      'operation-not-allowed' =>
        'Activa el acceso por correo y contraseña en Firebase Authentication.',
      'unauthorized-domain' =>
        'Este dominio no está autorizado para Firebase Auth. Añade el host actual en Authentication > Settings > Authorized domains.',
      'too-many-requests' =>
        'Hubo demasiados intentos. Espera un momento e inténtalo otra vez.',
      'network-request-failed' =>
        'No hay conexión. Revisa tu conexión a Internet.',
      'requires-recent-login' =>
        'Vuelve a iniciar sesión para realizar este cambio.',
      _ =>
        '${error.message ?? 'Firebase Authentication no pudo completar la operación.'} (código: ${error.code})',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' =>
        'Firebase denegó el acceso. Revisa las reglas de Cloud Firestore.',
      'unavailable' =>
        'Cloud Firestore no está disponible. Comprueba tu conexión e inténtalo de nuevo.',
      'failed-precondition' =>
        'Cloud Firestore necesita configuración adicional para esta operación.',
      _ =>
        '${error.message ?? 'Cloud Firestore no pudo completar la operación.'} (código: ${error.code})',
    };
  }
  if (error is StateError) {
    return error.message;
  }
  if (error is ArgumentError) {
    return error.message?.toString() ?? 'Revisa los datos ingresados.';
  }
  return 'No se pudo completar la operación: $error';
}
