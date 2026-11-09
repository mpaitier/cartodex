import 'package:flutter/material.dart';

import '../../../domain/entities/progress_count.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../stats/widgets/progress_count_label.dart';
import '../../stats/widgets/stacked_progress_bar.dart';
import 'missing_cards_label.dart';
import 'series_percent_label.dart';
import 'series_rarity_scope_button.dart';

/// Bandeau en haut de chaque série de l'accueil : où en est la
/// collection sur l'ensemble des sets de la série.
///
/// Même lecture que l'écran de statistiques : barre violette du
/// compte principal prolongée en jaune par ce que les secondaires
/// ajoutent, détail "X (+Y) / Z" et pourcentages du principal et de
/// l'apport des secondaires ([SeriesPercentLabel]). En face du
/// détail, le nombre de cartes que personne ne possède encore, en
/// rouge ([MissingCardsLabel]). Le bouton de droite
/// ([SeriesRarityScopeButton]) restreint le tout aux losanges ou aux
/// étoiles, nombre de cartes manquantes compris.
///
/// Composant purement visuel : la progression arrive déjà calculée
/// pour le périmètre [scope], et l'appui sur le bouton remonte via
/// [onScopePressed].
class SeriesProgressBanner extends StatelessWidget {
  const SeriesProgressBanner({
    required this.title,
    required this.progress,
    required this.scope,
    required this.onScopePressed,
    super.key,
  });

  /// Nom de la série (ex: "Série A", "Deluxe").
  final String title;

  final ProgressCount progress;
  final RarityScope scope;
  final VoidCallback onScopePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SeriesPercentLabel(
                        progress: progress,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StackedProgressBar(progress: progress),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: ProgressCountLabel(progress: progress)),
                      MissingCardsLabel(missing: progress.missing),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            SeriesRarityScopeButton(scope: scope, onPressed: onScopePressed),
          ],
        ),
      ),
    );
  }
}
