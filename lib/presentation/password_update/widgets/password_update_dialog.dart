import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/form_error_text.dart';
import '../../../l10n/l10n.dart';
import '../bloc/password_update_cubit.dart';
import '../bloc/password_update_state.dart';
import 'password_field.dart';

/// Popup des paramètres pour le mot de passe du compte cloud connecté.
///
/// - [hasPassword] faux (compte créé avec Google) : « Définir un mot
///   de passe », avec nouveau mot de passe et confirmation. Le compte
///   garde Google et pourra aussi se connecter avec [email] et ce mot
///   de passe.
/// - [hasPassword] vrai : « Changer le mot de passe », avec en plus le
///   mot de passe actuel.
///
/// Se ferme d'elle-même en renvoyant `true` une fois le mot de passe
/// enregistré ; `null` si l'utilisateur annule. Un échec s'affiche dans
/// la popup, qui reste ouverte.
class PasswordUpdateDialog extends StatelessWidget {
  const PasswordUpdateDialog({
    required this.email,
    required this.hasPassword,
    super.key,
  });

  final String email;
  final bool hasPassword;

  static Future<bool?> show(
    BuildContext context, {
    required String email,
    required bool hasPassword,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) =>
          PasswordUpdateDialog(email: email, hasPassword: hasPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PasswordUpdateCubit>(),
      child: _PasswordUpdateView(email: email, hasPassword: hasPassword),
    );
  }
}

class _PasswordUpdateView extends StatefulWidget {
  const _PasswordUpdateView({required this.email, required this.hasPassword});

  final String email;
  final bool hasPassword;

  @override
  State<_PasswordUpdateView> createState() => _PasswordUpdateViewState();
}

class _PasswordUpdateViewState extends State<_PasswordUpdateView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordUpdateCubit, PasswordUpdateState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == PasswordUpdateStatus.success,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final l10n = context.l10n;
        final isSaving = state.isSaving;
        return AlertDialog(
          title: Text(
            widget.hasPassword
                ? l10n.settingsChangePassword
                : l10n.settingsSetPassword,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.hasPassword) ...[
                    Text(l10n.passwordSetMessage(widget.email)),
                    const SizedBox(height: 8),
                  ],
                  if (widget.hasPassword)
                    PasswordField(
                      controller: _currentController,
                      label: l10n.passwordCurrentLabel,
                      enabled: !isSaving,
                      autofocus: true,
                      validator: _requiredValidator,
                    ),
                  PasswordField(
                    controller: _newController,
                    label: l10n.passwordNewLabel,
                    enabled: !isSaving,
                    autofocus: !widget.hasPassword,
                    validator: _newPasswordValidator,
                  ),
                  PasswordField(
                    controller: _confirmController,
                    label: l10n.passwordConfirmLabel,
                    enabled: !isSaving,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _submit,
                    validator: _confirmValidator,
                  ),
                  if (state.status == PasswordUpdateStatus.failure)
                    FormErrorText(
                      message: state.errorMessage ?? l10n.genericError,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return context.l10n.commonRequired;
    return null;
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.length < AppConstants.minPasswordLength) {
      return context.l10n.loginPasswordTooShort(AppConstants.minPasswordLength);
    }
    if (widget.hasPassword && value == _currentController.text) {
      return context.l10n.passwordSameAsCurrent;
    }
    return null;
  }

  String? _confirmValidator(String? value) {
    if (value != _newController.text) return context.l10n.passwordMismatch;
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<PasswordUpdateCubit>();
    if (widget.hasPassword) {
      cubit.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
    } else {
      cubit.linkPassword(_newController.text);
    }
  }
}
