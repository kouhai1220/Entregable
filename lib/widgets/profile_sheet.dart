// Hoja (bottom sheet) del perfil del usuario.
//
// Se abre desde la cabecera y muestra el nombre, el correo y el avatar del
// usuario. Permite editar el nombre, cerrar sesión (con confirmación) y
// reutiliza firebaseErrorMessage para mostrar los errores en español.
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

/// Panel inferior con la información y las acciones del perfil.
class ProfileSheet extends StatefulWidget {
  const ProfileSheet({
    required this.profile,
    required this.onSave,
    required this.onSignOut,
    super.key,
  });

  final UserProfile profile;
  final Future<void> Function(UserProfile) onSave;
  final Future<void> Function() onSignOut;

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late UserProfile _profile;
  bool _editing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Pide confirmación antes de cerrar la sesión del usuario.
  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Volverás a la pantalla de acceso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    Navigator.of(context).pop();
    await widget.onSignOut();
  }

  /// Guarda el nuevo nombre del perfil y actualiza la vista; si falla,
  /// muestra el error correspondiente.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _profile.email,
    );
    setState(() => _isSaving = true);
    try {
      await widget.onSave(profile);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firebaseErrorMessage(error))),
      );
      setState(() => _isSaving = false);
      return;
    }
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _editing = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: AppTheme.accent,
                  child: Text(
                    _profile.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editing ? 'Editar perfil' : 'Mi perfil',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (!_editing) ...[
                        const SizedBox(height: 3),
                        Text(
                          _profile.name,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _profile.email,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_editing) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Escribe tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _profile.email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editing = false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ListTile(
                key: const ValueKey('edit-profile'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar perfil'),
                onTap: () => setState(() => _editing = true),
              ),
              ListTile(
                key: const ValueKey('profile-sign-out'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.logout,
                  color: colors.error,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: colors.error),
                ),
                onTap: _confirmSignOut,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
