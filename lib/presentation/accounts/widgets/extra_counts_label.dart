import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rarity_symbol.dart';
import '../../../domain/entities/account_extras.dart';

/// Les cartes en plus d'un compte secondaire, sur une ligne : une
/// petite boîte pour les losanges, une pour les étoiles (ex : "◆ +12"
/// et "★ +3"), avec les images officielles des symboles
/// ([RaritySymbol]).
///
/// Une boîte à zéro reste affichée mais grisée, pour que la ligne
/// garde la même forme d'un compte à l'autre.
///
/// Le cadre d'une boîte passe au vert ([AppColors.complete]) quand
/// [completesBase] ou [completesAlternative] est vrai : les cartes en
/// plus de ce compte complètent alors le principal de ce côté (voir
/// `SetExtras.completesBase`). Sinon, il est jaune s'il y a des cartes
/// en plus, neutre sinon.
class ExtraCountsLabel extends StatelessWidget {
  const ExtraCountsLabel({
    required this.counts,
    this.completesBase = false,
    this.completesAlternative = false,
    super.key,
  });

  final ExtraCounts counts;
  final bool completesBase;
  final bool completesAlternative;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExtraCountBox(
          symbol: const RaritySymbol.diamond(),
          count: counts.base,
          completes: completesBase,
        ),
        const SizedBox(width: 6),
        _ExtraCountBox(
          symbol: const RaritySymbol.star(),
          count: counts.alternative,
          completes: completesAlternative,
        ),
      ],
    );
  }
}

class _ExtraCountBox extends StatelessWidget {
  const _ExtraCountBox({
    required this.symbol,
    required this.count,
    required this.completes,
  });

  final Widget symbol;
  final int count;
  final bool completes;

  /// Opacité du symbole d'une boîte à zéro : une image ne se grise pas
  /// comme un texte, on l'estompe à la place.
  static const double _emptySymbolOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExtra = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: completes
              ? AppColors.complete
              : hasExtra
                  ? AppColors.ownedBySecondaryAccount
                  : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: hasExtra ? 1 : _emptySymbolOpacity,
            child: symbol,
          ),
          const SizedBox(width: 4),
          Text(
            '+$count',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: hasExtra ? FontWeight.bold : FontWeight.normal,
              color: hasExtra ? null : theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
