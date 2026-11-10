import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Confirmation avant l'ajout en masse au compte principal (bouton
/// "+" de [SetDetailPage][../view/set_detail_page.dart]). Le nombre
/// de cartes concernées dépend du volet actif de
/// [CardGridPager][card_grid_pager.dart] et des filtres en cours
/// (booster, rareté) : ce texte le rend explicite avant une action
/// qui peut toucher beaucoup de cartes d'un coup.
class BulkAddConfirmationDialog extends StatelessWidget {
  const BulkAddConfirmationDialog({required this.cardCount, super.key});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.bulkAddTitle),
      content: Text(l10n.bulkAddMessage(cardCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.commonAdd),
        ),
      ],
    );
  }
}
