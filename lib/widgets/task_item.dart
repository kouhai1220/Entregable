// Widget que representa una tarea dentro de la lista del panel principal.
//
// Muestra la casilla para completar, el título, la categoría (con su color
// propio según la categoría y el modo claro/oscuro), la fecha y el botón para
// activar o desactivar el recordatorio.
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

/// Fila/tarjeta con la información de una tarea y sus acciones.
class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.task,
    required this.onToggleCompleted,
    required this.onToggleReminder,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggleCompleted;
  final VoidCallback onToggleReminder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final badgeColors = switch (task.category) {
      TaskCategory.trabajo => (
        const Color(0xFF4F46D3),
        const Color(0xFFedecff),
        const Color(0xFFaba7ff),
        const Color(0x335B53DC),
      ),
      TaskCategory.estudio => (
        const Color(0xFFA65F14),
        const Color(0xFFFFF2DC),
        const Color(0xFFF1B86F),
        const Color(0x29E0923A),
      ),
      TaskCategory.personal => (
        const Color(0xFF168365),
        const Color(0xFFE3F7F0),
        const Color(0xFF6ED5B5),
        const Color(0x2446AF8A),
      ),
    };
    final badgeColor = colors.brightness == Brightness.dark
        ? badgeColors.$3
        : badgeColors.$1;
    final badgeBackground = colors.brightness == Brightness.dark
        ? badgeColors.$4
        : badgeColors.$2;

    return Container(
      constraints: const BoxConstraints(minHeight: 67),
      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: task.completed
                ? 'Marcar ${task.title} como pendiente'
                : 'Completar ${task.title}',
            child: GestureDetector(
              onTap: onToggleCompleted,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: task.completed ? AppTheme.accent : Colors.transparent,
                  border: Border.all(
                    color: task.completed
                        ? AppTheme.accent
                        : const Color(0xFFCFD3DF),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: task.completed
                    ? const AppIcon(
                        AppIconName.check,
                        size: 15,
                        color: Colors.white,
                        strokeWidth: 2.6,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: task.completed
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        task.category.label,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        task.dueLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: task.reminder
                ? 'Desactivar recordatorio'
                : 'Activar recordatorio',
            onPressed: onToggleReminder,
            style: IconButton.styleFrom(
              fixedSize: const Size(29, 29),
              padding: EdgeInsets.zero,
              backgroundColor: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            icon: AppIcon(
              AppIconName.bell,
              size: 18,
              color: task.reminder ? AppTheme.accent : const Color(0xFFB7BBC7),
            ),
          ),
        ],
      ),
    );
  }
}
