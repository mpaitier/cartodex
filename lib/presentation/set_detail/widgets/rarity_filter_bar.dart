import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';

/// Barre horizontale de filtre par rareté, multi-sélection : chaque
/// palier se coche indépendamment (`FilterChip`), plus un choix
/// "Tout" (`ChoiceChip`) qui vide la sélection — un ensemble vide
/// signifie "aucun filtre actif", pas "rien à afficher".
///
/// Se rend invisible si le set n'a qu'une seule rareté distincte :
/// le filtre n'apporterait rien dans ce cas.
class RarityFilterBar extends StatelessWidget {
  const RarityFilterBar({
    required this.availableRarities,
    required this.selectedRarities,
    required this.onSelectionChanged,
    super.key,
  });

  final List<CardRarity> availableRarities;

  /// Vide = "Tout" (aucun filtre actif).
  final Set<CardRarity> selectedRarities;

  final ValueChanged<Set<CardRarity>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (availableRarities.length <= 1) {
      return const SizedBox.shrink();
    }
    final allSelected = selectedRarities.isEmpty;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: availableRarities.length + 1,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Tout'),
              selected: allSelected,
              onSelected: (_) => onSelectionChanged(const {}),
            );
          }
          final rarity = availableRarities[index - 1];
          final selected = selectedRarities.contains(rarity);
          return FilterChip(
            label: Text(rarity.symbol),
            selected: selected,
            onSelected: (isSelected) {
              final updated = Set<CardRarity>.from(selectedRarities);
              if (isSelected) {
                updated.add(rarity);
              } else {
                updated.remove(rarity);
              }
              onSelectionChanged(updated);
            },
          );
        },
      ),
    );
  }
}