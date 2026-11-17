import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/progress_count.dart';

/// Remplissage d'une barre de progression, sans coins arrondis : fond
/// gris, prolongé en jaune par ce que les comptes secondaires possèdent
/// en plus, puis le segment violet du compte principal (vert quand il
/// couvre à lui seul tout le total).
///
/// Ne s'arrondit pas lui-même, pour pouvoir être mis bout à bout dans
/// une seule barre continue (voir `RaritySplitProgressBar`) ; c'est le
/// conteneur qui arrondit les extrémités (voir `StackedProgressBar`).
/// Prend toute la place que lui donne son parent.
class StackedProgressFill extends StatelessWidget {
  const StackedProgressFill({required this.progress, super.key});

  final ProgressCount progress;

  @override
  Widget build(BuildContext context) {
    final primaryRatio = progress.primaryRatio.clamp(0.0, 1.0);
    final combinedRatio =
        (progress.primaryRatio + progress.secondaryExtraRatio).clamp(0.0, 1.0);
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        _Segment(
          widthFactor: combinedRatio,
          color: AppColors.ownedBySecondaryAccount,
        ),
        _Segment(
          widthFactor: primaryRatio,
          color: progress.isComplete
              ? AppColors.complete
              : AppColors.progressPrimary,
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: 1,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}
