// Pantallas de autenticación: inicio de sesión y registro.
//
// Contiene LoginScreen y RegisterScreen (con sus widgets privados de apoyo
// _AuthLayout, _AuthHeading, _AuthField, etc.) y los diálogos auxiliares para
// recuperar la contraseña y mostrar los términos y la política de privacidad.
// No llama a Firebase directamente: comunica las acciones al AppShell por
// medio de callbacks.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Abre un diálogo para pedir el correo y disparar el envío del enlace de
/// recuperación de contraseña a través de [onReset].
Future<void> _showPasswordRecovery(
  BuildContext context,
  Future<void> Function(String email) onReset,
) async {
  final controller = TextEditingController();
  final email = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Correo electrónico'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Enviar enlace'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (email != null && email.trim().isNotEmpty) await onReset(email);
}

Future<void> _showTerms(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Términos y Política de privacidad'),
      content: const Text(
        'La aplicación usa Firebase Authentication para gestionar tu cuenta '
        'y Cloud Firestore para sincronizar tu perfil y tus tareas con el '
        'proyecto Firebase configurado por quien publica la app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

/// Pantalla de inicio de sesión con correo y contraseña.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.darkMode,
    required this.onToggleTheme,
    required this.onLogin,
    required this.onPasswordReset,
    required this.onRegister,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final Future<void> Function(String email, String password) onLogin;
  final Future<void> Function(String email) onPasswordReset;
  final VoidCallback onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await widget.onLogin(_emailController.text, _passwordController.text);
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      darkMode: widget.darkMode,
      onToggleTheme: widget.onToggleTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(compact: true),
          const SizedBox(height: 24),
          const _AuthHeading(
            kicker: 'Qué bueno verte',
            title: '¡Bienvenido de nuevo!',
            description:
                'Inicia sesión para continuar organizando tus objetivos.',
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _AuthField(
                  icon: AppIconName.mail,
                  label: 'Correo electrónico',
                  placeholder: 'tu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Escribe un correo válido',
                ),
                _AuthField(
                  icon: AppIconName.lock,
                  label: 'Contraseña',
                  placeholder: 'Introduce tu contraseña',
                  password: true,
                  controller: _passwordController,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        _showPasswordRecovery(context, widget.onPasswordReset),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppTheme.accent,
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 18),
                _AuthSubmitButton(
                  label: 'Iniciar Sesión',
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _AuthSwitcher(
            prefix: '¿No tienes una cuenta?',
            action: 'Regístrate aquí',
            onPressed: widget.onRegister,
          ),
        ],
      ),
    );
  }
}

/// Pantalla de registro de un nuevo usuario (nombre, correo y contraseña).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.darkMode,
    required this.onToggleTheme,
    required this.onRegister,
    required this.onLogin,
    super.key,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final Future<void> Function(
    String name,
    String email,
    String password,
  )
  onRegister;
  final VoidCallback onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TapGestureRecognizer _termsRecognizer;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showTerms(context);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acepta los términos para continuar.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await widget.onRegister(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _AuthLayout(
      darkMode: widget.darkMode,
      onToggleTheme: widget.onToggleTheme,
      register: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(compact: true),
          const SizedBox(height: 17),
          const _AuthHeading(
            kicker: 'Empieza hoy',
            title: 'Crea tu cuenta',
            description:
                'Todo lo que necesitas para mantener tus tareas bajo control.',
            compact: true,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _AuthField(
                  icon: AppIconName.user,
                  label: 'Nombre completo',
                  placeholder: 'Tu nombre',
                  compact: true,
                  controller: _nameController,
                ),
                _AuthField(
                  icon: AppIconName.mail,
                  label: 'Correo electrónico',
                  placeholder: 'tu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  compact: true,
                  controller: _emailController,
                  validator: (value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Escribe un correo válido',
                ),
                _AuthField(
                  icon: AppIconName.lock,
                  label: 'Contraseña',
                  placeholder: 'Mínimo 8 caracteres',
                  password: true,
                  compact: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                _AuthField(
                  icon: AppIconName.lock,
                  label: 'Confirmar contraseña',
                  placeholder: 'Repite tu contraseña',
                  password: true,
                  compact: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) =>
                            setState(() => _acceptedTerms = value ?? false),
                        activeColor: AppTheme.accent,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 7,
                              height: 1.55,
                            ),
                            children: [
                              const TextSpan(text: 'Acepto los '),
                              TextSpan(
                                text: 'Términos y la Política de privacidad',
                                style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AuthSubmitButton(
                  label: 'Registrarse',
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AuthSwitcher(
            prefix: '¿Ya tienes una cuenta?',
            action: 'Inicia sesión',
            onPressed: widget.onLogin,
          ),
        ],
      ),
    );
  }
}

/// Estructura común de las pantallas de autenticación: fondo decorativo,
/// contenido desplazable y botón de cambio de tema en la esquina.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.darkMode,
    required this.onToggleTheme,
    required this.child,
    this.register = false,
  });

  final bool darkMode;
  final VoidCallback onToggleTheme;
  final Widget child;
  final bool register;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -55,
          child: Container(
            width: 205,
            height: 205,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.055),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(26, register ? 24 : 31, 26, 42),
            child: child,
          ),
        ),
        Positioned(
          top: 11,
          right: 21,
          child: ThemeToggleButton(
            darkMode: darkMode,
            onPressed: onToggleTheme,
          ),
        ),
      ],
    );
  }
}

/// Encabezado con el antetítulo, el título y la descripción de cada pantalla.
class _AuthHeading extends StatelessWidget {
  const _AuthHeading({
    required this.kicker,
    required this.title,
    required this.description,
    this.compact = false,
  });

  final String kicker;
  final String title;
  final String description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 17 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: compact ? 21 : 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 9,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de texto reutilizable con icono, etiqueta y validación; incluye el
/// botón para mostrar u ocultar la contraseña.
class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.icon,
    required this.label,
    required this.placeholder,
    this.password = false,
    this.compact = false,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  final AppIconName icon;
  final String label;
  final String placeholder;
  final bool password;
  final bool compact;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              widget.label,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: widget.compact ? 41 : 46,
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.password && !_visible,
              validator:
                  widget.validator ??
                  (value) => value == null || value.isEmpty
                      ? 'Este campo es obligatorio'
                      : null,
              style: TextStyle(color: colors.onSurface, fontSize: 9),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 9),
                  child: AppIcon(
                    widget.icon,
                    size: 18,
                    color: const Color(0xFFA1A6B6),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 39,
                  minHeight: 18,
                ),
                suffixIcon: widget.password
                    ? IconButton(
                        tooltip: _visible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () => setState(() => _visible = !_visible),
                        padding: const EdgeInsets.all(3),
                        icon: const AppIcon(
                          AppIconName.eye,
                          size: 17,
                          color: Color(0xFF777E91),
                        ),
                      )
                    : null,
                hintStyle: const TextStyle(
                  color: Color(0xFFA7ABB8),
                  fontSize: 9,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón principal (ancho completo) para enviar el formulario.
class _AuthSubmitButton extends StatelessWidget {
  const _AuthSubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 47,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accentDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Enlace inferior para alternar entre iniciar sesión y registrarse.
class _AuthSwitcher extends StatelessWidget {
  const _AuthSwitcher({
    required this.prefix,
    required this.action,
    required this.onPressed,
  });

  final String prefix;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            prefix,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 8),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppTheme.accent,
            textStyle: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
