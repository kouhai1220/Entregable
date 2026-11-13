// Modelo de datos del dominio de las tareas.
//
// Este archivo define:
// - TaskCategory: las categorías posibles de una tarea.
// - TaskFilter: los filtros que se usan en la pantalla principal.
// - TaskModel: la tarea en sí, con su conversión a/desde un Map para poder
//   guardarla y leerla en Cloud Firestore.

/// Categorías disponibles de una tarea, con la etiqueta visible en la interfaz.
enum TaskCategory {
  trabajo('Trabajo'),
  personal('Personal'),
  estudio('Estudio');

  const TaskCategory(this.label);

  final String label;

  /// Obtiene la categoría a partir de su etiqueta (por defecto, trabajo).
  static TaskCategory fromLabel(String label) => TaskCategory.values.firstWhere(
    (category) => category.label == label,
    orElse: () => TaskCategory.trabajo,
  );
}

/// Filtros disponibles en el panel principal para acotar las tareas visibles.
enum TaskFilter {
  todas('Todas'),
  pendientes('Pendientes'),
  trabajo('Trabajo'),
  estudio('Estudio');

  const TaskFilter(this.label);

  final String label;
}

/// Representa una tarea: id, título, categoría, fecha mostrada, recordatorio,
/// estado de completado, descripción y fecha/hora real ([dueAt]).
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dueLabel,
    required this.reminder,
    required this.completed,
    this.description = '',
    this.dueAt,
  });

  final int id;
  final String title;
  final TaskCategory category;
  final String dueLabel;
  final bool reminder;
  final bool completed;
  final String description;
  final DateTime? dueAt;

  /// Devuelve una copia de la tarea con los campos indicados reemplazados.
  TaskModel copyWith({
    String? title,
    TaskCategory? category,
    String? dueLabel,
    bool? reminder,
    bool? completed,
    String? description,
    DateTime? dueAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueLabel: dueLabel ?? this.dueLabel,
      reminder: reminder ?? this.reminder,
      completed: completed ?? this.completed,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
    );
  }

  /// Serializa la tarea a un Map para poder guardarla en Firestore.
  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'category': category.label,
    'dueLabel': dueLabel,
    'reminder': reminder,
    'completed': completed,
    'description': description,
    'dueAt': dueAt?.toIso8601String(),
  };

  /// Crea una tarea a partir de un Map leído de Firestore.
  factory TaskModel.fromMap(Map<String, Object?> map) => TaskModel(
    id: map['id']! as int,
    title: map['title']! as String,
    category: TaskCategory.fromLabel(map['category']! as String),
    dueLabel: map['dueLabel']! as String,
    reminder: map['reminder']! as bool,
    completed: map['completed']! as bool,
    description: map['description'] as String? ?? '',
    dueAt: DateTime.tryParse(map['dueAt'] as String? ?? ''),
  );
}
