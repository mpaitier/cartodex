import 'package:flutter/material.dart';

import '../../../domain/entities/card_element.dart';
import 'card_element_style.dart';

/// Barre de puces du filtre par type : "Tout", puis une puce par
/// élément présent dans le set (pastille de couleur et libellé, voir
/// [CardElementStyle]). Multi-sélection, comme le filtre de rareté :
/// cocher plusieurs éléments affiche les cartes de l'un ou de l'autre.
///
/// Masquée quand le set n'a qu'un seul élément à proposer : le filtre
/// n'aurait rien à départager. Composant purement visuel : la
/// sélection remonte via [onSelectionChanged].
class ElementFilterBar extends StatelessWidget {
  const ElementFilterBar({
    required this.availableElements,
    required this.selectedElements,
    required this.onSelectionChanged,
    super.key,
  });

  final List<CardElement> availableElements;

  /// Vide signifie "tous les types".
  final Set<CardElement> selectedElements;

  final ValueChanged<Set<CardElement>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (availableElements.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: availableElements.length + 1,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Tout'),
              selected: selectedElements.isEmpty,
              showCheckmark: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onSelectionChanged(const {}),
            );
          }
          final element = availableElements[index - 1];
          return FilterChip(
            avatar: _ElementDot(color: element.color),
            label: Text(element.label),
            selected: selectedElements.contains(element),
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (isSelected) {
              final updated = Set<CardElement>.from(selectedElements);
              if (isSelected) {
                updated.add(element);
              } else {
                updated.remove(element);
              }
              onSelectionChanged(updated);
            },
          );
        },
      ),
    );
  }
}

class _ElementDot extends StatelessWidget {
  const _ElementDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
