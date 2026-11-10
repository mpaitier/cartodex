import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../core/widgets/card_rarity_icon.dart';
import 'filter_chip_wrap.dart';

/// Barre de filtre par rareté, multi-sélection : chaque
/// palier se coche indépendamment (`FilterChip`), plus un choix
/// "Tous" (`ChoiceChip`) qui vide la sélection — un ensemble vide
/// signifie "aucun filtre actif", pas "rien à afficher".
///
/// Chaque puce montre la rareté avec les images officielles du jeu
/// ([CardRarityIcon]).
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

  /// Vide = "Tous" (aucun filtre actif).
  final Set<CardRarity> selectedRarities;

  final ValueChanged<Set<CardRarity>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (availableRarities.length <= 1) {
      return const SizedBox.shrink();
    }
    final allSelected = selectedRarities.isEmpty;
    return FilterChipWrap(
      itemCount: availableRarities.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ChoiceChip(
            label: const Text('Tous'),
            selected: allSelected,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onSelectionChanged(const {}),
          );
        }
        final rarity = availableRarities[index - 1];
        final selected = selectedRarities.contains(rarity);
        return FilterChip(
          label: CardRarityIcon(rarity: rarity, size: 14),
          selected: selected,
          showCheckmark: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
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
    );
  }
}