import 'package:flutter/material.dart';

import '../../../core/widgets/unique_cards_icon.dart';
import '../../../l10n/l10n.dart';

/// Puce du détail d'un set qui n'affiche que les cartes uniques du
/// compte secondaire sélectionné, celles qu'aucun autre compte ne
/// possède. Son libellé donne leur nombre ([count]), qu'elle soit
/// cochée ou non : on sait combien il y en a avant même de filtrer.
///
/// Utilisée à deux endroits : sous le sous-filtre par compte du
/// panneau de filtres, et dans le bandeau d'un set ouvert depuis le
/// profil d'un compte (`OwnerFilterBanner`).
class UniqueCardsFilterChip extends StatelessWidget {
  const UniqueCardsFilterChip({
    required this.count,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final int count;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Tooltip(
      message: l10n.uniqueCardsTooltip,
      child: FilterChip(
        avatar: const UniqueCardsIcon(size: 18),
        label: Text(l10n.uniqueCardsFilter(count)),
        selected: selected,
        showCheckmark: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        onSelected: onSelected,
      ),
    );
  }
}
