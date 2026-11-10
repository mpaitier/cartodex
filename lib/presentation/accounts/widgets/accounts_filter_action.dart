import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Bouton de la barre du haut de l'onglet des comptes : ouvre le
/// panneau de tri et de filtre
/// ([AccountsFilterSheet][accounts_filter_sheet.dart]).
///
/// Une pastille signale un filtre par extension actif, pour qu'une
/// liste réduite ne passe pas pour une liste incomplète. Le tri n'en
/// affiche pas : il ne cache aucun compte. Composant purement visuel :
/// l'appui remonte via [onPressed].
class AccountsFilterAction extends StatelessWidget {
  const AccountsFilterAction({
    required this.isFiltered,
    required this.onPressed,
    super.key,
  });

  final bool isFiltered;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.accountsSortAndFilter,
      icon: Badge(
        isLabelVisible: isFiltered,
        child: const Icon(Icons.tune),
      ),
    );
  }
}
