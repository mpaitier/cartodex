import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/percent_formatter.dart';
import '../../../domain/entities/progress_count.dart';

/// Pourcentages du bandeau de série (ex: "34,28 % +5,71 %").
///
/// - le premier, en violet (vert quand la série est complète), est la
///   part du compte principal ;
/// - le second, en jaune et précédé d'un "+", est ce que les comptes
///   secondaires ajoutent sans doublon avec le principal (même lecture
///   que le "(+Y)" de `ProgressCountLabel`). Il est masqué quand les
///   secondaires n'apportent rien.
///
/// Deux décimales arrondies vers le bas (voir [PercentFormatter]).
/// Un tiret quand le périmètre ne contient aucune carte (ex: les
/// losanges d'une série de promos).
class SeriesPercentLabel extends StatelessWidget {
  const SeriesPercentLabel({required this.progress, this.style, super.key});

  final ProgressCount progress;

  /// Style de base ; le thème `titleSmall` par défaut.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleSmall;
    if (progress.total == 0) return Text('–', style: baseStyle);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: PercentFormatter.twoDecimals(progress.owned, progress.total),
            style: TextStyle(
              color: progress.isComplete
                  ? AppColors.complete
                  : AppColors.progressPrimary,
            ),
          ),
          if (progress.secondaryExtra > 0)
            TextSpan(
              text: ' +${PercentFormatter.twoDecimals(
                progress.secondaryExtra,
                progress.total,
              )}',
              style: const TextStyle(color: AppColors.ownedBySecondaryAccount),
            ),
        ],
      ),
      maxLines: 1,
    );
  }
}
