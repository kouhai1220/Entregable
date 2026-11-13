// Pantalla de estado vacío.
//
// Se muestra cuando el usuario no tiene tareas. Incluye una ilustración
// decorativa, un mensaje de "todo bajo control" y botones para crear una
// tarea o volver al panel principal.
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Vista que se muestra cuando no hay tareas pendientes.
class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({
    required this.darkMode,
    required this.onToggleTheme,
    required this.profileName,
    required this.onOpenProfile,
    required this.onAdd,
    required this.onBack,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final String profileName;
  final VoidCallback onOpenProfile;
  final VoidCallback onAdd;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Column(
          children: [
            AppHeader(
              darkMode: darkMode,
              onToggleTheme: onToggleTheme,
              profileName: profileName,
              onOpenProfile: onOpenProfile,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 52),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _EmptyIllustration(),
                          const SizedBox(height: 8),
                          Text(
                            'No hay tareas pendientes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Todo está bajo control. Disfruta este momento o empieza a planificar tu próximo objetivo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: onAdd,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 19,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            icon: const AppIcon(
                              AppIconName.plus,
                              size: 19,
                              color: Colors.white,
                            ),
                            label: const Text('Crear una tarea'),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: onBack,
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onSurfaceVariant,
                              textStyle: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Volver a mis tareas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Ilustración decorativa (tarjetas y círculos) de la pantalla vacía.
class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      height: 195,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 21,
            child: _Orb(
              diameter: 175,
              color: AppTheme.accent.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 45,
            left: 56,
            child: _Orb(
              diameter: 105,
              color: AppTheme.accent.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            top: 33,
            left: 37,
            child: Transform.rotate(
              angle: -0.19,
              child: _EmptyCard(
                color: colors.surface,
                borderColor: colors.outlineVariant,
                children: const [
                  _SkeletonLine(width: null),
                  _SkeletonLine(widthFactor: 0.75),
                  _SkeletonLine(widthFactor: 0.5),
                ],
              ),
            ),
          ),
          Positioned(
            top: 31,
            right: 34,
            child: Transform.rotate(
              angle: 0.14,
              child: _EmptyCard(
                color: colors.surface,
                borderColor: colors.outlineVariant,
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          blurRadius: 17,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppIcon(
                        AppIconName.check,
                        size: 30,
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const _SkeletonLine(widthFactor: 1),
                  const _SkeletonLine(widthFactor: 0.6),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 10,
            child: Transform.rotate(
              angle: 0.3,
              child: const Text(
                '+',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 42,
            child: Text(
              '·',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo semitransparente usado como fondo decorativo de la ilustración.
class _Orb extends StatelessWidget {
  const _Orb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Tarjeta con esquinas redondeadas y sombra usada en la ilustración.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.color,
    required this.borderColor,
    required this.children,
  });

  final Color color;
  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      constraints: const BoxConstraints(minHeight: 129),
      padding: const EdgeInsets.fromLTRB(17, 20, 17, 15),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Línea gris que simula texto dentro de las tarjetas de la ilustración.
class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({this.width, this.widthFactor});

  final double? width;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        width: width,
        height: 5,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
