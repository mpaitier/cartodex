import 'package:flutter/material.dart';

/// Popup de création d'un compte : nom (affiché dans l'app) et
/// identifiant du compte de jeu (stocké mais jamais affiché
/// ailleurs — voir [Account.gameAccountId][../../../domain/entities/account.dart]).
class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({required this.onSubmit, super.key});

  final void Function(String name, String gameAccountId) onSubmit;

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gameAccountIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _gameAccountIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un compte'),
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
                labelText: 'Identifiant du compte',
                helperText: "Ne sera pas affiché ailleurs dans l'app",
              ),
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
          child: const Text('Ajouter'),
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