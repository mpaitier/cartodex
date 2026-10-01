import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/account.dart';

/// Popup ouvert au double-tap sur une carte : choisit le compte
/// secondaire dont la possession de cette carte doit basculer.
///
/// N'affiche que les comptes secondaires ([Account.isPrimary] à
/// `false`) — le tap simple couvre déjà le principal. Une flèche
/// jaune indique les comptes qui possèdent déjà la carte.
class SecondaryAccountPickerDialog extends StatelessWidget {
  const SecondaryAccountPickerDialog({
    required this.accounts,
    required this.ownedByAccountId,
    required this.onAccountSelected,
    super.key,
  });

  /// Comptes secondaires parmi lesquels choisir.
  final List<Account> accounts;

  /// Identifiants des comptes de [accounts] qui possèdent déjà
  /// cette carte.
  final Set<String> ownedByAccountId;

  final ValueChanged<String> onAccountSelected;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return AlertDialog(
        title: const Text('Aucun compte secondaire'),
        content: const Text(
          "Crée d'abord un compte secondaire depuis l'écran Comptes.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text('Compte secondaire'),
      children: [
        for (final account in accounts)
          SimpleDialogOption(
            onPressed: () {
              onAccountSelected(account.id);
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: ownedByAccountId.contains(account.id)
                      ? AppColors.ownedBySecondaryAccount
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(account.name)),
              ],
            ),
          ),
      ],
    );
  }
}