import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../l10n/l10n.dart';

/// Ligne d'information d'une tuile de set : nombre de cartes et
/// nombre de boosters sur une même ligne (ex: "286 cartes · 3
/// boosters"). Un set sans booster connu n'affiche que les cartes.
///
/// Les pluriels suivent les règles de chaque langue (clés `cardCount`
/// et `boosterCount` des fichiers ARB) : en français, "0 carte" et
/// "1 carte" restent au singulier.
class CardSetInfoLine extends StatelessWidget {
  const CardSetInfoLine({required this.set, super.key});

  final CardSet set;

  String _text(AppLocalizations l10n) {
    final parts = <String>[l10n.cardCount(set.totalCardCount)];
    if (set.packs.isNotEmpty) {
      parts.add(l10n.boosterCount(set.packs.length));
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text(context.l10n),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
