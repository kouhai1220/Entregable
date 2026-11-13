// Pantalla de bienvenida (splash).
//
// Se muestra al abrir la app: presenta el logo y el nombre "MisTareas" con
// puntos animados. Al tocarla (o al pulsar) se llama a onContinue, que
// restaura la sesión del usuario y decide a dónde ir.
import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';

/// Pantalla inicial con el logo de la app y una invitación a continuar.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.onContinue,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onContinue;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isLoading ? null : onContinue,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.7, -1),
            end: const Alignment(0.7, 1),
            colors: darkMode
                ? const [
                    Color(0xFF312E81),
                    Color(0xFF211D63),
                    Color(0xFF17153F),
                  ]
                : const [
                    Color(0xFF5650E8),
                    Color(0xFF4338CA),
                    Color(0xFF302A9E),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 24),
                    const Text(
                      'MisTareas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Organiza. Enfócate. Avanza.',
                      style: TextStyle(
                        color: Color(0xB0FFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 78,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LoadingDot(delay: 0),
                  SizedBox(width: 6),
                  _LoadingDot(delay: 150),
                  SizedBox(width: 6),
                  _LoadingDot(delay: 300),
                ],
              ),
            ),
            Positioned(
              bottom: 45,
              left: 0,
              right: 0,
              child: Text(
                isLoading ? 'CONECTANDO...' : 'TOCA PARA CONTINUAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0x7AFFFFFF),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punto animado (con parpadeo y retardo) de la fila de carga del splash.
class _LoadingDot extends StatefulWidget {
  const _LoadingDot({required this.delay});

  final int delay;

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: const CircleAvatar(
        radius: 2.5,
        backgroundColor: Color(0xB0FFFFFF),
      ),
    );
  }
}
