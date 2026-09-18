import 'package:flutter/material.dart';

import '../../../domain/entities/account.dart';

/// Une ligne de la liste de comptes : nom et étoile.
///
/// L'étoile est pleine et jaune pour le compte principal, non
/// interactive ; en contour gris pour les autres, et cliquable
/// (l'appui échange le rôle avec le principal actuel — voir
/// [AccountsBloc][../bloc/accounts_bloc.dart]).
class AccountListItem extends StatelessWidget {
  const AccountListItem({
    required this.account,
    required this.onCrownTap,
    super.key,
  });

  final Account account;
  final VoidCallback onCrownTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(account.name),
      trailing: IconButton(
        onPressed: account.isPrimary ? null : onCrownTap,
        tooltip: account.isPrimary
            ? 'Compte principal'
            : 'Définir comme compte principal',
        icon: Icon(
          account.isPrimary ? Icons.star : Icons.star_border,
          color: account.isPrimary ? Colors.amber[700] : Colors.grey,
        ),
      ),
    );
  }
}