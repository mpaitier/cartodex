import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/percent_formatter.dart';
import '../../../domain/entities/progress_count.dart';
import '../../../l10n/l10n.dart';

/// Pourcentages du bandeau de série (ex: "34,28 % +5,71 % (40,00 %)").
///
/// - le premier, en violet (vert quand la série est complète), est la
///   part du compte principal ;
/// - le deuxième, en jaune et précédé d'un "+", est ce que les comptes
///   secondaires ajoutent sans doublon avec le principal (même lecture
///   que le "(+Y)" de `ProgressCountLabel`) ;
/// - le dernier, entre parenthèses et en couleur atténuée, est la part
///   possédée par au moins un compte.
///
/// Les deux derniers sont masqués quand les secondaires n'apportent
/// rien : le total serait alors identique au premier.
///
/// Chaque valeur est arrondie vers le bas séparément (voir
/// [PercentFormatter]) : le total peut donc dépasser de 0,01 la somme
/// des deux premiers, mais n'affiche 100,00 % que si plus rien ne
/// manque.
///
/// Un tiret quand le périmètre ne contient aucune carte (ex: les
/// losanges d'une série de promos).
///
/// Le séparateur décimal et la place du signe % suivent la langue de
/// l'app ("34,28 %" en français, "34.28%" en anglais).
class SeriesPercentLabel extends StatelessWidget {
  const SeriesPercentLabel({required this.progress, this.style, super.key});

  final ProgressCount progress;

  /// Style de base ; le thème `titleSmall` par défaut.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.titleSmall;
    if (progress.total == 0) return Text('–', style: baseStyle);

    final l10n = context.l10n;
    String percent(int part) => l10n.percentValue(
          PercentFormatter.twoDecimals(
            part,
            progress.total,
            decimalSeparator: l10n.decimalSeparator,
          ),
        );

    final hasSecondaryExtra = progress.secondaryExtra > 0;
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: percent(progress.owned),
            style: TextStyle(
              color: progress.isComplete
                  ? AppColors.complete
                  : AppColors.progressPrimary,
            ),
          ),
          if (hasSecondaryExtra) ...[
            TextSpan(
              text: ' +${percent(progress.secondaryExtra)}',
              style: const TextStyle(color: AppColors.ownedBySecondaryAccount),
            ),
            TextSpan(
              text: ' (${percent(progress.owned + progress.secondaryExtra)})',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
      maxLines: 1,
    );
  }
}
