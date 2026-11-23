import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/form_error_text.dart';
import '../../../core/widgets/password_field.dart';
import '../../../domain/entities/app_user.dart';
import '../../../l10n/l10n.dart';
import '../bloc/delete_account_cubit.dart';
import '../bloc/delete_account_state.dart';
import 'delete_local_data_tile.dart';

/// Popup de suppression du compte cloud de [user].
///
/// Explique ce qui sera effacé, propose d'effacer aussi la collection
/// du téléphone ([DeleteLocalDataTile]) et demande une confirmation
/// d'identité, exigée par Firebase : le mot de passe pour un compte
/// qui en a un, sinon le choix du compte Google au moment de
/// supprimer.
///
/// Se ferme d'elle-même en renvoyant `true` une fois le compte
/// supprimé ; `null` si l'utilisateur annule. Un échec s'affiche dans
/// la popup, qui reste ouverte.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({required this.user, super.key});

  final AppUser user;

  static Future<bool?> show(BuildContext context, {required AppUser user}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteAccountDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeleteAccountCubit>(),
      child: _DeleteAccountView(user: user),
    );
  }
}

class _DeleteAccountView extends StatefulWidget {
  const _DeleteAccountView({required this.user});

  final AppUser user;

  @override
  State<_DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<_DeleteAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _deleteLocalData = false;

  bool get _usesPassword => widget.user.hasPasswordSignIn;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == DeleteAccountStatus.success,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final l10n = context.l10n;
        final colorScheme = Theme.of(context).colorScheme;
        final isDeleting = state.isDeleting;
        final label = widget.user.email ?? widget.user.displayName ?? '';
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          title: Text(l10n.deleteAccountTitle),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.deleteAccountMessage(label)),
                  const SizedBox(height: 8),
                  DeleteLocalDataTile(
                    value: _deleteLocalData,
                    enabled: !isDeleting,
                    onChanged: (value) =>
                        setState(() => _deleteLocalData = value),
                  ),
                  const SizedBox(height: 8),
                  if (_usesPassword) ...[
                    Text(l10n.deleteAccountPasswordHint),
                    PasswordField(
                      controller: _passwordController,
                      label: l10n.loginPasswordLabel,
                      enabled: !isDeleting,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.commonRequired
                          : null,
                    ),
                  ] else
                    Text(l10n.deleteAccountGoogleHint),
                  if (state.status == DeleteAccountStatus.failure)
                    FormErrorText(
                      message: state.errorMessage ?? l10n.genericError,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: isDeleting ? null : _submit,
              child: isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onError,
                      ),
                    )
                  : Text(l10n.deleteAccountConfirm),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DeleteAccountCubit>().delete(
          userId: widget.user.uid,
          password: _usesPassword ? _passwordController.text : null,
          deleteLocalData: _deleteLocalData,
        );
  }
}
