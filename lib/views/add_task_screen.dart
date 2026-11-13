// Pantalla de creación de una nueva tarea.
//
// Muestra un formulario (título, descripción, categoría, fecha, hora y
// recordatorio) y, al guardar, construye un TaskModel que se envía a la app
// principal mediante el callback onSave.
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Formulario para crear una tarea nueva.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    required this.darkMode,
    required this.onToggleTheme,
    required this.onBack,
    required this.onSave,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onBack;
  final ValueChanged<TaskModel> onSave;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 30);
  TaskCategory _category = TaskCategory.trabajo;
  bool _reminder = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Abre el selector de fecha del sistema.
  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) setState(() => _date = selectedDate);
  }

  /// Abre el selector de hora del sistema.
  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (selectedTime != null) setState(() => _time = selectedTime);
  }

  /// Valida el formulario y construye la tarea con los datos introducidos,
  /// formateando fecha y hora para mostrarlas en la lista.
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final dueAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final month = const [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ][_date.month - 1];
    final hour = _time.hour.toString().padLeft(2, '0');
    final minute = _time.minute.toString().padLeft(2, '0');
    widget.onSave(
      TaskModel(
        id: DateTime.now().microsecondsSinceEpoch,
        title: _titleController.text.trim(),
        category: _category,
        dueLabel: '${_date.day} $month, $hour:$minute',
        reminder: _reminder,
        completed: false,
        description: _descriptionController.text.trim(),
        dueAt: dueAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(21, 13, 21, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderIconButton(
                    tooltip: 'Volver',
                    onPressed: widget.onBack,
                    icon: AppIconName.arrow,
                  ),
                  Text(
                    'Nueva tarea',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ThemeToggleButton(
                    darkMode: widget.darkMode,
                    onPressed: widget.onToggleTheme,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  key: const ValueKey('task-form-scroll'),
                  padding: const EdgeInsets.fromLTRB(21, 20, 21, 42),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: AppIcon(
                              AppIconName.check,
                              size: 22,
                              strokeWidth: 2.3,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Qué necesitas hacer?',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Organiza tu día, una tarea a la vez.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _FieldLabel(
                      label: 'Título de la tarea',
                      child: TextFormField(
                        key: const ValueKey('task-title-field'),
                        controller: _titleController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: colors.onSurface, fontSize: 10),
                        decoration: const InputDecoration(
                          hintText: 'Ej. Preparar la presentación',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Escribe un título para la tarea'
                            : null,
                      ),
                    ),
                    _FieldLabel(
                      label: 'Descripción',
                      optional: true,
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: colors.onSurface, fontSize: 10),
                        decoration: const InputDecoration(
                          hintText: 'Añade notas o detalles importantes...',
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    _FieldLabel(
                      label: 'Categoría',
                      child: DropdownButtonFormField<TaskCategory>(
                        initialValue: _category,
                        icon: const AppIcon(
                          AppIconName.chevron,
                          size: 18,
                          color: Color(0xFF777E91),
                        ),
                        items: TaskCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                        style: TextStyle(color: colors.onSurface, fontSize: 10),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _FieldLabel(
                            label: 'Fecha',
                            child: _DateTimeField(
                              icon: AppIconName.calendar,
                              label:
                                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                              onTap: _selectDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: _FieldLabel(
                            label: 'Hora',
                            child: _DateTimeField(
                              icon: AppIconName.clock,
                              label:
                                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                              onTap: _selectTime,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: AppIcon(
                                AppIconName.bell,
                                size: 18,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recordatorio',
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Te avisaremos a tiempo',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _reminder,
                            onChanged: (value) =>
                                setState(() => _reminder = value),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const ValueKey('save-task'),
                      onPressed: _titleController.text.trim().isEmpty
                          ? null
                          : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(47),
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.accent.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const AppIcon(
                        AppIconName.check,
                        size: 19,
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                      label: const Text('Guardar Tarea'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Botón cuadrado de la cabecera (por ejemplo, "Volver").
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final AppIconName icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(37, 37),
        padding: EdgeInsets.zero,
        backgroundColor: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      icon: AppIcon(icon, size: 20, color: colors.onSurface),
    );
  }
}

/// Etiqueta con marca opcional ("Opcional") que precede a cada campo.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(text: label),
                  if (optional)
                    TextSpan(
                      text: '  Opcional',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Campo de solo lectura (fecha u hora) que abre el selector al pulsarlo.
class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppIconName icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AppIcon(icon, size: 18, color: AppTheme.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onSurface, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
