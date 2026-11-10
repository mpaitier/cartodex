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
/// Trois lignes :
/// 1. nom de la série, et à droite les pourcentages du principal, de
///    l'apport des secondaires et du total ([SeriesPercentLabel]) ;
/// 2. barre violette du compte principal prolongée en jaune par ce
///    que les secondaires ajoutent (fond gris pour le reste), et à
///    droite le bouton de périmètre ([SeriesRarityScopeButton]) qui
///    restreint le bandeau aux losanges ou aux étoiles ;
/// 3. nombre de cartes que personne ne possède, en rouge pâle
///    ([MissingCardsLabel]), et à droite le détail "X (+Y) / Z"
///    ([ProgressCountLabel]).
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
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _TitleRow(title: title, progress: progress),
            _BarRow(
              progress: progress,
              scope: scope,
              onScopePressed: onScopePressed,
            ),
            _CountsRow(progress: progress),
          ],
        ),
      ),
    );
  }
}

/// Ligne 1 : nom de la série et pourcentages.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.progress});

  final String title;
  final ProgressCount progress;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
        const SizedBox(width: 8),
        SeriesPercentLabel(progress: progress, style: titleStyle),
      ],
    );
  }
}

/// Ligne 2 : barre de progression et bouton de périmètre.
class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.progress,
    required this.scope,
    required this.onScopePressed,
  });

  final ProgressCount progress;
  final RarityScope scope;
  final VoidCallback onScopePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: StackedProgressBar(progress: progress)),
        const SizedBox(width: 8),
        SeriesRarityScopeButton(scope: scope, onPressed: onScopePressed),
      ],
    );
  }
}

/// Ligne 3 : cartes manquantes et détail "X (+Y) / Z".
class _CountsRow extends StatelessWidget {
  const _CountsRow({required this.progress});

  final ProgressCount progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MissingCardsLabel(missing: progress.missing),
        const Spacer(),
        ProgressCountLabel(progress: progress),
      ],
    );
  }
}
