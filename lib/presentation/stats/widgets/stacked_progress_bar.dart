import 'package:flutter/material.dart';

import '../../../domain/entities/progress_count.dart';
import 'stacked_progress_fill.dart';

/// Barre de progression en deux parties : le segment violet du
/// compte principal, prolongé par un segment jaune pour ce que les
/// comptes secondaires possèdent en plus (voir [ProgressCount]).
///
/// Mêmes couleurs que la bordure des tuiles de sets
/// (`SetProgressBorder`) : le segment du principal passe au vert
/// quand il couvre, à lui seul, tout le total. Le dessin lui-même est
/// fait par [StackedProgressFill] ; ce widget lui donne sa hauteur et
/// ses extrémités arrondies.
class StackedProgressBar extends StatelessWidget {
  const StackedProgressBar({
    required this.progress,
    this.height = 8,
    super.key,
  });

  final ProgressCount progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: StackedProgressFill(progress: progress),
      ),
    );
  }
}
