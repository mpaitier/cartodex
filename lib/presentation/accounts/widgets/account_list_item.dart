import 'package:flutter/material.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import 'account_edit_button.dart';
import 'extra_counts_label.dart';
import 'primary_account_star_button.dart';

/// Une ligne de la liste de comptes : nom, puis à droite le bouton
/// crayon ([AccountEditButton]) et l'étoile du compte principal
/// ([PrimaryAccountStarButton]).
///
/// La marge de droite de la ligne est réduite : les deux boutons ont
/// déjà leur propre zone d'appui, qui suffit à décoller l'étoile du
/// bord de l'écran.
///
/// Pour un compte secondaire, [extras] affiche sous le nom les cartes
/// qu'il possède en plus du principal (losanges / étoiles), et [onTap]
/// ouvre le détail par set. Le compte principal n'a ni l'un ni
/// l'autre.
class AccountListItem extends StatelessWidget {
  const AccountListItem({
    required this.account,
    required this.onCrownTap,
    required this.onEditTap,
    this.extras,
    this.onTap,
    super.key,
  });

  final Account account;
  final VoidCallback onCrownTap;
  final VoidCallback onEditTap;

  /// `null` pour le compte principal.
  final AccountExtras? extras;

  /// `null` pour le compte principal : la ligne n'est alors pas
  /// cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final extras = this.extras;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AccountEditButton(onPressed: onEditTap),
          PrimaryAccountStarButton(
            isPrimary: account.isPrimary,
            onPressed: onCrownTap,
          ),
        ],
      ),
    );
  }
}
