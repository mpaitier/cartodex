import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text('Ajouter ces cartes ?'),
      content: Text(
        'Les $cardCount cartes actuellement affichées seront marquées '
        'comme possédées par le compte principal.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}