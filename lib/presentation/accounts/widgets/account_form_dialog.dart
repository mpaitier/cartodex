import 'package:flutter/material.dart';

/// Popup de saisie d'un compte : nom (affiché dans l'app) et code ami
/// (stocké mais jamais affiché ailleurs — voir
/// [Account.gameAccountId][../../../domain/entities/account.dart]).
///
/// Formulaire commun à l'ajout ([AddAccountDialog][add_account_dialog.dart])
/// et à la modification ([EditAccountDialog][edit_account_dialog.dart]),
/// qui ne fournissent que leurs textes et leurs valeurs de départ.
/// Les deux champs sont obligatoires ; les espaces en début et fin
/// sont retirés avant [onSubmit].
class AccountFormDialog extends StatefulWidget {
  const AccountFormDialog({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialGameAccountId = '',
    super.key,
  });

  final String title;

  /// Libellé du bouton de validation (ex: "Ajouter", "Enregistrer").
  final String submitLabel;

  final void Function(String name, String gameAccountId) onSubmit;

  final String initialName;
  final String initialGameAccountId;

  @override
  State<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gameAccountIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _gameAccountIdController =
        TextEditingController(text: widget.initialGameAccountId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gameAccountIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              textInputAction: TextInputAction.next,
              validator: _requiredValidator,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gameAccountIdController,
              decoration: const InputDecoration(
                labelText: 'Code ami',
                helperText: "Ne sera pas affiché ailleurs dans l'app",
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: _requiredValidator,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Requis' : null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      _nameController.text.trim(),
      _gameAccountIdController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}
