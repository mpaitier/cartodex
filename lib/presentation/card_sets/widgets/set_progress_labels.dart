import 'package:flutter/material.dart';

import '../../../domain/entities/set_progress.dart';
import 'set_progress_half_label.dart';

/// Ligne de pourcentages sous une tuile de set : losanges à gauche,
/// étoiles à droite, chacun sous la moitié de bordure qu'il décrit,
/// séparés par un filet vertical.
class SetProgressLabels extends StatelessWidget {
  const SetProgressLabels({required this.progress, super.key});

  final SetProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SetProgressHalfLabel(symbol: '◆', progress: progress.base),
        ),
        Container(
          width: 1,
          height: 14,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: SetProgressHalfLabel(
            symbol: '★',
            progress: progress.alternative,
          ),
        ),
      ],
    );
  }
}