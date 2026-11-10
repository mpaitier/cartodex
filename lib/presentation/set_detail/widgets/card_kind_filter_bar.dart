import 'package:flutter/material.dart';

import '../../../domain/entities/card_kind.dart';
import '../../../l10n/l10n.dart';
import 'card_element_logo.dart';
import 'card_kind_style.dart';
import 'filter_chip_wrap.dart';

/// Barre de puces du filtre par type : "Tous", puis une puce par type
/// présent dans le set. Les éléments de Pokémon viennent d'abord et
/// n'affichent que leur logo officiel ([CardElementLogo]), comme les
/// raretés n'affichent que leur symbole ; leur nom apparaît en
/// infobulle, et à côté d'une pastille de couleur si le logo est
/// introuvable. Les types de Dresseur suivent, avec une icône et leur
/// nom (voir [CardKindStyle]). Multi-sélection, comme le filtre de rareté :
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
    final l10n = context.l10n;
    return FilterChipWrap(
      itemCount: availableKinds.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ChoiceChip(
            label: Text(l10n.commonAll),
            selected: selectedKinds.isEmpty,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onSelectionChanged(const {}),
          );
        }
        final kind = availableKinds[index - 1];
        return FilterChip(
          avatar: kind.isElement ? null : _TrainerKindIcon(kind: kind),
          label: kind.isElement
              ? CardElementLogo(
                  kind: kind,
                  errorBuilder: (_) => _ElementFallback(kind: kind),
                )
              : Text(kind.label(l10n)),
          tooltip: kind.label(l10n),
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

/// Icône d'un type de Dresseur ou d'un type inconnu, devant son nom.
class _TrainerKindIcon extends StatelessWidget {
  const _TrainerKindIcon({required this.kind});

  final CardKind kind;

  @override
  Widget build(BuildContext context) {
    return Icon(
      kind.icon,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

/// Repli d'une puce d'élément quand son logo est introuvable :
/// pastille de la couleur de l'élément et son nom.
class _ElementFallback extends StatelessWidget {
  const _ElementFallback({required this.kind});

  final CardKind kind;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: kind.color ?? Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(kind.label(context.l10n)),
      ],
    );
  }
}
