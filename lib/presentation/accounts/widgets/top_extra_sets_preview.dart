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
/// Rien n'est affiché quand le compte n'a aucune carte en plus ; avec
/// moins de [maxCount] sets, seules les cases utiles apparaissent.
class TopExtraSetsPreview extends StatelessWidget {
  const TopExtraSetsPreview({
    required this.sets,
    this.maxCount = 3,
    super.key,
  });

  final List<SetExtras> sets;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final shown = sets.take(maxCount).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _SetLogoBox(setExtras: shown[i]),
        ],
      ],
    );
  }
}

/// Une case de l'aperçu : le logo du set dans un petit cadre arrondi.
class _SetLogoBox extends StatelessWidget {
  const _SetLogoBox({required this.setExtras});

  final SetExtras setExtras;

  static const double _width = 44;
  static const double _height = 30;

  @override
  Widget build(BuildContext context) {
    final counts = setExtras.counts;
    return Tooltip(
      message: '${setExtras.set.name} : '
          '+${counts.base} ◆, +${counts.alternative} ★',
      child: Container(
        width: _width,
        height: _height,
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
