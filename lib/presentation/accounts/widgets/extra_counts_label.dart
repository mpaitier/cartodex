import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/account_extras.dart';

/// Les cartes en plus d'un compte secondaire, sur une ligne : une
/// petite boîte pour les losanges, une pour les étoiles (ex : "◆ +12"
/// et "★ +3").
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
        _ExtraCountBox(symbol: '◆', count: counts.base),
        const SizedBox(width: 6),
        _ExtraCountBox(symbol: '★', count: counts.alternative),
      ],
    );
  }
}

class _ExtraCountBox extends StatelessWidget {
  const _ExtraCountBox({required this.symbol, required this.count});

  final String symbol;
  final int count;

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
      child: Text(
        '$symbol +$count',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: hasExtra ? FontWeight.bold : FontWeight.normal,
          color: hasExtra ? null : theme.disabledColor,
        ),
      ),
    );
  }
}