import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/set_progress.dart';

/// Libellé d'une moitié de bordure : symbole et pourcentage du
/// compte principal (ex: "◆ 93 %"), suivi en jaune de ce que les
/// comptes secondaires ajoutent (ex: "+7").
///
/// Les pourcentages sont arrondis à l'entier inférieur, pour ne
/// jamais afficher 100 % tant qu'il manque une carte. Le gain des
/// secondaires se calcule sur ces valeurs arrondies, de sorte que la
/// somme des deux chiffres colle toujours au total affiché.
class SetProgressHalfLabel extends StatelessWidget {
  const SetProgressHalfLabel({
    required this.symbol,
    required this.progress,
    super.key,
  });

  final String symbol;
  final RarityGroupProgress progress;

  static int _percent(int owned, int total) => (owned * 100) ~/ total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.labelSmall;

    if (progress.isEmpty) {
      return Text(
        '$symbol –',
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(color: theme.disabledColor),
      );
    }

    final primaryPercent = _percent(progress.primaryOwned, progress.total);
    final allPercent = _percent(progress.allAccountsOwned, progress.total);
    final extraPercent = allPercent - primaryPercent;
    final complete = progress.isPrimaryComplete;

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: '$symbol $primaryPercent %',
            style: TextStyle(
              color: complete ? AppColors.complete : AppColors.progressPrimary,
              fontWeight: complete ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (extraPercent > 0)
            TextSpan(
              text: ' +$extraPercent',
              style: const TextStyle(color: AppColors.ownedBySecondaryAccount),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}