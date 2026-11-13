// Widgets e iconos reutilizables de toda la aplicación.
//
// Contiene:
// - AppIconName y AppIcon: iconos vectoriales propios (dibujados con
//   CustomPainter) para no depender de un paquete de iconos externo.
// - ThemeToggleButton: botón para cambiar entre modo claro y oscuro.
// - AppLogo: el logo (cuadrado con un check) usado en splash y autenticación.
// - AppHeader: cabecera reutilizable con el título, el cambio de tema y el
//   avatar del usuario.
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Nombres de los iconos disponibles que sabe dibujar [AppIcon].
enum AppIconName {
  sun,
  moon,
  bell,
  plus,
  search,
  arrow,
  calendar,
  clock,
  chevron,
  check,
  inbox,
  mail,
  lock,
  user,
  eye,
}

/// Icono vectorial propio: dibuja el trazo correspondiente a [name] con
/// [CustomPaint], con tamaño, color y grosor configurables.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.8,
  });

  final AppIconName name;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AppIconPainter(
        name,
        color ?? Theme.of(context).colorScheme.onSurface,
        strokeWidth,
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter(this.name, this.color, this.strokeWidth);

  final AppIconName name;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();

    switch (name) {
      case AppIconName.check:
        path
          ..moveTo(6, 12)
          ..lineTo(10, 16)
          ..lineTo(18, 8);
      case AppIconName.plus:
        path
          ..moveTo(12, 5)
          ..lineTo(12, 19)
          ..moveTo(5, 12)
          ..lineTo(19, 12);
      case AppIconName.search:
        canvas.drawCircle(const Offset(11, 11), 6.5, paint);
        path
          ..moveTo(16, 16)
          ..lineTo(20.5, 20.5);
      case AppIconName.arrow:
        path
          ..moveTo(15, 18)
          ..lineTo(9, 12)
          ..lineTo(15, 6);
      case AppIconName.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 5, 18, 16),
            const Radius.circular(3),
          ),
          paint,
        );
        path
          ..moveTo(8, 3)
          ..lineTo(8, 7)
          ..moveTo(16, 3)
          ..lineTo(16, 7)
          ..moveTo(3, 10)
          ..lineTo(21, 10);
      case AppIconName.clock:
        canvas.drawCircle(const Offset(12, 12), 9, paint);
        path
          ..moveTo(12, 7)
          ..lineTo(12, 12)
          ..lineTo(15, 14);
      case AppIconName.chevron:
        path
          ..moveTo(8, 10)
          ..lineTo(12, 14)
          ..lineTo(16, 10);
      case AppIconName.bell:
        path
          ..moveTo(18, 8)
          ..cubicTo(18, 4, 6, 4, 6, 8)
          ..cubicTo(6, 15, 3, 15, 3, 17)
          ..lineTo(21, 17)
          ..cubicTo(21, 15, 18, 15, 18, 8)
          ..moveTo(10, 21)
          ..lineTo(14, 21);
      case AppIconName.inbox:
        path
          ..moveTo(4.5, 5.5)
          ..lineTo(19.5, 5.5)
          ..lineTo(22, 14.5)
          ..lineTo(22, 18.5)
          ..quadraticBezierTo(22, 20.5, 20, 20.5)
          ..lineTo(4, 20.5)
          ..quadraticBezierTo(2, 20.5, 2, 18.5)
          ..lineTo(2, 14.5)
          ..close()
          ..moveTo(2.5, 14.5)
          ..lineTo(7.5, 14.5)
          ..lineTo(9, 16.5)
          ..lineTo(15, 16.5)
          ..lineTo(16.5, 14.5)
          ..lineTo(21.5, 14.5);
      case AppIconName.mail:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 5, 18, 14),
            const Radius.circular(3),
          ),
          paint,
        );
        path
          ..moveTo(4.5, 7)
          ..lineTo(12, 12)
          ..lineTo(19.5, 7);
      case AppIconName.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 10, 16, 11),
            const Radius.circular(3),
          ),
          paint,
        );
        path
          ..moveTo(8, 10)
          ..lineTo(8, 7)
          ..arcToPoint(const Offset(16, 7), radius: const Radius.circular(4))
          ..lineTo(16, 10)
          ..moveTo(12, 14)
          ..lineTo(12, 17);
      case AppIconName.user:
        canvas.drawCircle(const Offset(12, 8), 4, paint);
        path
          ..moveTo(4.5, 21)
          ..cubicTo(4.5, 11, 19.5, 11, 19.5, 21);
      case AppIconName.eye:
        path
          ..moveTo(2.5, 12)
          ..cubicTo(6, 5, 18, 5, 21.5, 12)
          ..cubicTo(18, 19, 6, 19, 2.5, 12)
          ..close();
        canvas.drawCircle(const Offset(12, 12), 2.5, paint);
      case AppIconName.sun:
        canvas.drawCircle(const Offset(12, 12), 3.7, paint);
        path
          ..moveTo(12, 2)
          ..lineTo(12, 4)
          ..moveTo(12, 20)
          ..lineTo(12, 22)
          ..moveTo(4.93, 4.93)
          ..lineTo(6.35, 6.35)
          ..moveTo(17.65, 17.65)
          ..lineTo(19.07, 19.07)
          ..moveTo(2, 12)
          ..lineTo(4, 12)
          ..moveTo(20, 12)
          ..lineTo(22, 12)
          ..moveTo(4.93, 19.07)
          ..lineTo(6.35, 17.65)
          ..moveTo(17.65, 6.35)
          ..lineTo(19.07, 4.93);
      case AppIconName.moon:
        path
          ..moveTo(20.2, 15.2)
          ..cubicTo(14, 17, 7, 10, 8.8, 3.8)
          ..cubicTo(1, 7, 4, 21, 13, 21)
          ..cubicTo(16, 21, 19, 19, 20.2, 15.2)
          ..close();
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter oldDelegate) =>
      oldDelegate.name != name ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Botón de la cabecera que alterna entre modo claro y oscuro.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    required this.darkMode,
    required this.onPressed,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: darkMode ? 'Activar modo claro' : 'Activar modo oscuro',
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
      icon: AppIcon(
        darkMode ? AppIconName.sun : AppIconName.moon,
        size: 19,
        color: colors.onSurface,
      ),
    );
  }
}

/// Logo de la app: cuadrado con un check, en versión normal o compacta.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 58 : 88,
      height: compact ? 58 : 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 18 : 28),
        gradient: compact
            ? const LinearGradient(
                colors: [Color(0xFF6257EF), Color(0xFF4438C7)],
              )
            : null,
        color: compact ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: compact ? 0.24 : 0.25),
            blurRadius: compact ? 25 : 45,
            offset: Offset(0, compact ? 12 : 21),
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          AppIconName.check,
          size: compact ? 25 : 38,
          strokeWidth: 2.5,
          color: compact ? Colors.white : AppTheme.accent,
        ),
      ),
    );
  }
}

/// Cabecera reutilizable: título, botón de tema y avatar del usuario.
class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.darkMode,
    required this.onToggleTheme,
    required this.profileName,
    required this.onOpenProfile,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final String profileName;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 13, 21, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Tareas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ThemeToggleButton(darkMode: darkMode, onPressed: onToggleTheme),
              const SizedBox(width: 9),
              Tooltip(
                message: 'Abrir perfil',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const ValueKey('open-profile'),
                    onTap: onOpenProfile,
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF747DE8), Color(0xFF4741B8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: colors.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials(profileName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'U' : initials;
  }
}
