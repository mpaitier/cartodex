import 'package:flutter/material.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import 'extra_counts_label.dart';

/// Une ligne de la liste de comptes : nom et étoile.
///
/// L'étoile est pleine et jaune pour le compte principal, non
/// interactive ; en contour gris pour les autres, et cliquable
/// (l'appui échange le rôle avec le principal actuel — voir
/// [AccountsBloc][../bloc/accounts_bloc.dart]).
///
/// Pour un compte secondaire, [extras] affiche sous le nom les cartes
/// qu'il possède en plus du principal (losanges / étoiles), et [onTap]
/// ouvre le détail par set. Le compte principal n'a ni l'un ni
/// l'autre.
class AccountListItem extends StatelessWidget {
  const AccountListItem({
    required this.account,
    required this.onCrownTap,
    this.extras,
    this.onTap,
    super.key,
  });

  final Account account;
  final VoidCallback onCrownTap;

  /// `null` pour le compte principal.
  final AccountExtras? extras;

  /// `null` pour le compte principal : la ligne n'est alors pas
  /// cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final extras = this.extras;
    return ListTile(
      title: Text(account.name),
      subtitle: extras == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExtraCountsLabel(counts: extras.totals),
              ),
            ),
      onTap: onTap,
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