import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';

/// Ligne d'information d'une tuile de set : nombre de cartes et
/// nombre de boosters sur une même ligne (ex: "286 cartes · 3
/// boosters"). Un set sans booster connu n'affiche que les cartes.
class CardSetInfoLine extends StatelessWidget {
  const CardSetInfoLine({required this.set, super.key});

  final CardSet set;

  String get _text {
    final parts = <String>[_plural(set.totalCardCount, 'carte')];
    if (set.packs.isNotEmpty) {
      parts.add(_plural(set.packs.length, 'booster'));
    }
    return parts.join(' · ');
  }

  /// Pluriel français : "0 carte", "1 carte", "2 cartes".
  static String _plural(int count, String noun) {
    return count > 1 ? '$count ${noun}s' : '$count $noun';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}