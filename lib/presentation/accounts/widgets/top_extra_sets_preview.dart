import 'package:flutter/material.dart';

import '../../../domain/entities/account_extras.dart';
import '../../card_sets/widgets/card_set_logo.dart';

/// Aperçu, sur une ligne de compte secondaire, des sets où il possède
/// le plus de cartes que le principal n'a pas : jusqu'à [maxCount]
/// cases, chacune avec le logo d'un set.
///
/// [sets] doit arriver déjà trié, du set le plus intéressant au moins
/// intéressant : c'est le cas de `AccountExtras.bySet` (losanges en
/// plus, puis étoiles en plus — voir `SetExtras.sortedByCounts`). Un
/// appui long sur une case affiche le nom du set et ses compteurs.
///
/// La zone garde toujours la largeur de [maxCount] cases, et les cases
/// se rangent depuis la gauche : avec un seul set, sa case est la
/// première de la zone, ce qui garde l'ordre d'importance lisible d'une
/// ligne à l'autre, et les noms des comptes restent alignés. Un compte
/// sans carte en plus garde la zone, vide.
class TopExtraSetsPreview extends StatelessWidget {
  const TopExtraSetsPreview({
    required this.sets,
    this.maxCount = 3,
    super.key,
  });

  final List<SetExtras> sets;
  final int maxCount;

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final shown = sets.take(maxCount).toList();
    return SizedBox(
      width: maxCount * _SetLogoBox.width + (maxCount - 1) * _gap,
      child: Row(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            _SetLogoBox(setExtras: shown[i]),
          ],
        ],
      ),
    );
  }
}

/// Une case de l'aperçu : le logo du set dans un petit cadre arrondi.
class _SetLogoBox extends StatelessWidget {
  const _SetLogoBox({required this.setExtras});

  final SetExtras setExtras;

  static const double width = 56;
  static const double height = 38;

  @override
  Widget build(BuildContext context) {
    final counts = setExtras.counts;
    return Tooltip(
      message: '${setExtras.set.name} : '
          '+${counts.base} ◆, +${counts.alternative} ★',
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CardSetLogo(url: setExtras.set.logoUrl),
        ),
      ),
    );
  }
}
