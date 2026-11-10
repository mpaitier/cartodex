import 'package:flutter/material.dart';

import '../../../domain/entities/card_kind.dart';
import 'card_element_logo.dart';
import 'card_kind_style.dart';
import 'filter_chip_wrap.dart';

/// Barre de puces du filtre par type : "Tous", puis une puce par type
/// présent dans le set, les éléments de Pokémon d'abord (logo officiel
/// de l'élément, voir [CardElementLogo]), les types de Dresseur
/// ensuite (icône, voir [CardKindStyle]). Multi-sélection, comme le filtre de rareté :
/// cocher plusieurs types affiche les cartes de l'un ou de l'autre.
///
/// Masquée quand le set n'a qu'un seul type à proposer : le filtre
/// n'aurait rien à départager. Composant purement visuel : la
/// sélection remonte via [onSelectionChanged].
class CardKindFilterBar extends StatelessWidget {
  const CardKindFilterBar({
    required this.availableKinds,
    required this.selectedKinds,
    required this.onSelectionChanged,
    super.key,
  });

  final List<CardKind> availableKinds;

  /// Vide signifie "tous les types".
  final Set<CardKind> selectedKinds;

  final ValueChanged<Set<CardKind>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (availableKinds.length <= 1) {
      return const SizedBox.shrink();
    }
    return FilterChipWrap(
      itemCount: availableKinds.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ChoiceChip(
            label: const Text('Tous'),
            selected: selectedKinds.isEmpty,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onSelectionChanged(const {}),
          );
        }
        final kind = availableKinds[index - 1];
        return FilterChip(
          avatar: _KindAvatar(kind: kind),
          label: Text(kind.label),
          selected: selectedKinds.contains(kind),
          showCheckmark: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          onSelected: (isSelected) {
            final updated = Set<CardKind>.from(selectedKinds);
            if (isSelected) {
              updated.add(kind);
            } else {
              updated.remove(kind);
            }
            onSelectionChanged(updated);
          },
        );
      },
    );
  }
}

/// Repère d'une puce : logo officiel pour un élément, icône pour un
/// type de Dresseur ou un type inconnu.
class _KindAvatar extends StatelessWidget {
  const _KindAvatar({required this.kind});

  final CardKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind.isElement) return CardElementLogo(kind: kind);
    return Icon(
      kind.icon,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
