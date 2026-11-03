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
class ExtraCountsLabel extends StatelessWidget {
  const ExtraCountsLabel({required this.counts, super.key});

  final ExtraCounts counts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExtraCountBox(
          symbol: const RaritySymbol.diamond(),
          count: counts.base,
        ),
        const SizedBox(width: 6),
        _ExtraCountBox(
          symbol: const RaritySymbol.star(),
          count: counts.alternative,
        ),
      ],
    );
  }
}

class _ExtraCountBox extends StatelessWidget {
  const _ExtraCountBox({required this.symbol, required this.count});

  final Widget symbol;
  final int count;

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
          color: hasExtra
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
