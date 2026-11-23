import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../l10n/l10n.dart';
import '../bloc/password_reset_cubit.dart';
import '../bloc/password_reset_state.dart';
import 'password_reset_email_field.dart';
import 'password_reset_error_text.dart';

/// Popup qui demande l'email du compte et y envoie un lien de
/// réinitialisation du mot de passe.
///
/// Se ferme d'elle-même une fois le lien envoyé, en renvoyant
/// l'adresse utilisée ; `null` si l'utilisateur annule. Un échec
/// s'affiche dans la popup, qui reste ouverte pour corriger l'email
/// ou réessayer. Pour enchaîner avec le message de confirmation, passer
/// par `PasswordResetFlow`.
class PasswordResetDialog extends StatelessWidget {
  const PasswordResetDialog({
    this.initialEmail,
    this.emailLocked = false,
    super.key,
  });

  /// Email pré-rempli (celui saisi sur l'écran de connexion, ou celui
  /// du compte connecté).
  final String? initialEmail;

  /// Empêche de modifier l'email : utilisé depuis les paramètres, où
  /// le lien part forcément à l'adresse du compte connecté.
  final bool emailLocked;

  static Future<String?> show(
    BuildContext context, {
    String? initialEmail,
    bool emailLocked = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => PasswordResetDialog(
        initialEmail: initialEmail,
        emailLocked: emailLocked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PasswordResetCubit>(),
      child: _PasswordResetView(
        initialEmail: initialEmail,
        emailLocked: emailLocked,
      ),
    );
  }
}

class _PasswordResetView extends StatefulWidget {
  const _PasswordResetView({
    required this.initialEmail,
    required this.emailLocked,
  });

  final String? initialEmail;
  final bool emailLocked;

  @override
  State<_PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends State<_PasswordResetView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController =
      TextEditingController(text: widget.initialEmail?.trim() ?? '');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == PasswordResetStatus.sent,
      listener: (context, state) => Navigator.of(context).pop(state.email),
      builder: (context, state) {
        final l10n = context.l10n;
        final isSending = state.isSending;
        return AlertDialog(
          title: Text(l10n.passwordResetTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.passwordResetMessage),
                const SizedBox(height: 16),
                PasswordResetEmailField(
                  controller: _emailController,
                  enabled: !isSending,
                  readOnly: widget.emailLocked,
                  onSubmitted: _submit,
                ),
                if (state.status == PasswordResetStatus.failure)
                  PasswordResetErrorText(
                    message: state.errorMessage ?? l10n.genericError,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: isSending ? null : _submit,
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.passwordResetSubmit),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PasswordResetCubit>().submit(
          email: _emailController.text,
          languageCode: Localizations.localeOf(context).languageCode,
        );
  }
}
