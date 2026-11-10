import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/split_outline_box.dart';
import '../../../domain/entities/account_extras.dart';
import '../../../l10n/l10n.dart';
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
///
/// Le cadre de chaque case passe au vert ([AppColors.complete]) côté
/// gauche quand les cartes en plus de ce compte complètent les
/// losanges du principal dans ce set, et côté droit quand elles
/// complètent les étoiles (voir `SetExtras.completesBase`).
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

/// Une case de l'aperçu : le logo du set dans un petit cadre arrondi,
/// coupé en deux moitiés ([SplitOutlineBox]) qui passent au vert quand
/// ce compte complète les losanges (gauche) ou les étoiles (droite).
class _SetLogoBox extends StatelessWidget {
  const _SetLogoBox({required this.setExtras});

  final SetExtras setExtras;

  static const double width = 56;
  static const double height = 38;

  @override
  Widget build(BuildContext context) {
    final counts = setExtras.counts;
    final neutral = Theme.of(context).colorScheme.outlineVariant;
    return Tooltip(
      message: context.l10n.setExtrasTooltip(
        setExtras.set.name,
        counts.base,
        counts.alternative,
      ),
      child: SplitOutlineBox(
        leftColor: setExtras.completesBase ? AppColors.complete : neutral,
        rightColor:
            setExtras.completesAlternative ? AppColors.complete : neutral,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CardSetLogo(url: setExtras.set.logoUrl),
          ),
        ),
      ),
    );
  }
}
