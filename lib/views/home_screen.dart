// Pantalla principal (panel de tareas).
//
// Recibe la lista de tareas ya cargada y permite buscarlas, filtrarlas por
// categoría/estado, ver el progreso del día, marcar tareas como completadas o
// activar recordatorios, y abrir el formulario para añadir una tarea nueva.
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/task_item.dart';

/// Panel principal con el listado, la búsqueda y los filtros de tareas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.tasks,
    required this.darkMode,
    required this.onToggleTheme,
    required this.profileName,
    required this.onOpenProfile,
    required this.onAdd,
    required this.onToggleTask,
    required this.onToggleReminder,
    required this.onShowEmpty,
    super.key,
  });

  final List<TaskModel> tasks;
  final bool darkMode;
  final VoidCallback onToggleTheme;
  final String profileName;
  final VoidCallback onOpenProfile;
  final VoidCallback onAdd;
  final ValueChanged<int> onToggleTask;
  final ValueChanged<int> onToggleReminder;
  final VoidCallback onShowEmpty;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter _filter = TaskFilter.todas;
  String _query = '';

  /// Tareas que cumplen el filtro seleccionado y coinciden con la búsqueda.
  List<TaskModel> get _visibleTasks {
    final normalizedQuery = _query.toLowerCase();
    return widget.tasks.where((task) {
      final matchesFilter =
          _filter == TaskFilter.todas ||
          (_filter == TaskFilter.pendientes && !task.completed) ||
          task.category.label == _filter.label;
      return matchesFilter &&
          task.title.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pendingCount = widget.tasks.where((task) => !task.completed).length;
    final completedCount = widget.tasks.length - pendingCount;
    final progress = widget.tasks.isEmpty
        ? 0.0
        : completedCount / widget.tasks.length;

    return Stack(
      children: [
        Column(
          children: [
            AppHeader(
              darkMode: widget.darkMode,
              onToggleTheme: widget.onToggleTheme,
              profileName: widget.profileName,
              onOpenProfile: widget.onOpenProfile,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                children: [
                  _ProgressCard(
                    pendingCount: pendingCount,
                    completedCount: completedCount,
                    taskCount: widget.tasks.length,
                    progress: progress,
                    onTap: widget.onShowEmpty,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        const AppIcon(
                          AppIconName.search,
                          size: 18,
                          color: Color(0xFFA0A5B5),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 11,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Buscar una tarea...',
                              hintStyle: TextStyle(
                                color: Color(0xFFA0A5B5),
                                fontSize: 11,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: TaskFilter.values.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 7),
                      itemBuilder: (context, index) {
                        final filter = TaskFilter.values[index];
                        return _FilterChip(
                          label: filter.label,
                          selected: _filter == filter,
                          onTap: () => setState(() => _filter = filter),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _filter == TaskFilter.todas
                              ? 'Para hoy'
                              : _filter.label,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${_visibleTasks.length} tareas',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_visibleTasks.isEmpty)
                    _InlineEmptyState(onTap: widget.onShowEmpty)
                  else
                    ..._visibleTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: TaskItem(
                          task: task,
                          onToggleCompleted: () => widget.onToggleTask(task.id),
                          onToggleReminder: () =>
                              widget.onToggleReminder(task.id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('add-task-fab'),
              onTap: widget.onAdd,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C50EB), Color(0xFF4439CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.38),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: AppIcon(
                    AppIconName.plus,
                    size: 27,
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta superior con el resumen del día (pendientes y progreso circular).
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.pendingCount,
    required this.completedCount,
    required this.taskCount,
    required this.progress,
    required this.onTap,
  });

  final int pendingCount;
  final int completedCount;
  final int taskCount;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(
              colors: [Color(0xFF4B43CF), Color(0xFF6864ED)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progreso de hoy',
                      style: TextStyle(
                        color: Color(0xB8FFFFFF),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pendingCount == 0
                          ? 'Todo listo'
                          : '$pendingCount tareas pendientes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Text(
                      '$completedCount/$taskCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip seleccionable para filtrar las tareas por estado o categoría.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? AppTheme.accent : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppTheme.accent : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : colors.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensaje que aparece dentro de la lista cuando no hay tareas que mostrar.
class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(26),
        foregroundColor: colors.onSurfaceVariant,
        side: BorderSide(
          color: colors.outlineVariant,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 10),
      ),
      icon: const AppIcon(
        AppIconName.inbox,
        size: 25,
        color: Color(0xFF777E91),
      ),
      label: const Text('No encontramos tareas'),
    );
  }
}
