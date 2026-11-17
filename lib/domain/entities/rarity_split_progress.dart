import 'package:equatable/equatable.dart';

import 'progress_count.dart';

/// Progression séparée entre les deux familles de raretés : la
/// collection de base (losanges) d'un côté, les cartes alternatives
/// (étoile, couronne, chromatique, ou sans rareté connue) de l'autre.
///
/// Sert à afficher une barre par famille quand le périmètre Σ couvre
/// les deux : chaque famille peut alors passer au vert seule, ce qu'une
/// barre unique cachait (voir `RaritySplitProgressBar`).
class RaritySplitProgress extends Equatable {
  const RaritySplitProgress({required this.base, required this.alternative});

  static const RaritySplitProgress zero = RaritySplitProgress(
    base: ProgressCount.zero,
    alternative: ProgressCount.zero,
  );

  /// Cartes losange.
  final ProgressCount base;

  /// Cartes non-losange.
  final ProgressCount alternative;

  /// Les deux familles réunies : le compteur du périmètre Σ.
  ProgressCount get combined => base + alternative;

  /// Somme famille par famille (agrégation de plusieurs sets).
  RaritySplitProgress operator +(RaritySplitProgress other) {
    return RaritySplitProgress(
      base: base + other.base,
      alternative: alternative + other.alternative,
    );
  }

  @override
  List<Object?> get props => [base, alternative];
}
