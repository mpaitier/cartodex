import 'package:flutter/material.dart';

import '../../../core/widgets/rarity_symbol.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../../domain/entities/set_progress.dart';
import 'set_progress_half_label.dart';

/// Ligne de pourcentages sous une tuile de set : losanges à gauche,
/// étoiles à droite (images officielles, voir `RaritySymbol`), chacun
/// sous la moitié de bordure qu'il décrit, séparés par un filet
/// vertical.
///
/// La moitié exclue par [rarityScope] (périmètre de raretés global)
/// reste lisible mais estompée, comme sa moitié de bordure : la
/// largeur de la ligne ne change pas d'un périmètre à l'autre.
class SetProgressLabels extends StatelessWidget {
  const SetProgressLabels({
    required this.progress,
    this.rarityScope = RarityScope.all,
    super.key,
  });

  /// Opacité d'une moitié hors périmètre.
  static const double _excludedOpacity = 0.35;

  final SetProgress progress;
  final RarityScope rarityScope;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _half(
            included: rarityScope != RarityScope.star,
            child: SetProgressHalfLabel(
              symbol: const RaritySymbol.diamond(size: 10),
              progress: progress.base,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 14,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _half(
            included: rarityScope != RarityScope.diamond,
            child: SetProgressHalfLabel(
              symbol: const RaritySymbol.star(size: 10),
              progress: progress.alternative,
            ),
          ),
        ),
      ],
    );
  }

  Widget _half({required bool included, required Widget child}) {
    if (included) return child;
    return Opacity(opacity: _excludedOpacity, child: child);
  }
}
