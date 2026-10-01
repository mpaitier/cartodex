import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/set_progress.dart';
import 'card_set_info_line.dart';
import 'card_set_logo.dart';
import 'set_progress_border.dart';
import 'set_progress_labels.dart';

/// Une tuile de la grille de sets : logo, nom, nombre de cartes et de
/// boosters, et la progression du compte principal (bordure coupée
/// en deux et pourcentages ◆ / ★ — voir [SetProgressBorder]).
///
/// Composant purement visuel, sans connaissance du Bloc parent :
/// toute interaction remonte via [onTap]. Sans [progress] (aucun
/// compte principal, ou calcul indisponible), la bordure reste
/// neutre et la ligne de pourcentages disparaît.
class CardSetGridItem extends StatelessWidget {
  const CardSetGridItem({
    required this.set,
    required this.onTap,
    this.progress,
    super.key,
  });

  final CardSet set;
  final VoidCallback onTap;
  final SetProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = this.progress;
    // La marge de 4 reproduit celle que `Card` applique par défaut :
    // elle doit rester à l'extérieur de la bordure, sinon celle-ci
    // se dessinerait dans le vide autour de la carte.
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SetProgressBorder(
        progress: progress,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SetProgressBorder.cornerRadius),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(SetProgressBorder.strokeWidth),
              child: Column(
                children: [
                  Expanded(child: CardSetLogo(url: set.logoUrl)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                    child: Column(
                      children: [
                        Text(
                          set.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                        CardSetInfoLine(set: set),
                        if (progress != null) ...[
                          const SizedBox(height: 4),
                          SetProgressLabels(progress: progress),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}