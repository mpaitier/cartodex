import 'package:equatable/equatable.dart';

import 'pack_variant_pull_rates.dart';

/// Probabilités de tirage des boosters d'un set (ex: "A1"), telles
/// que publiées par `pokemon-tcg-pocket-database` (`pullRates.json`).
///
/// Elles sont communes à tous les boosters du set : à Genetic Apex,
/// les boosters Charizard, Mewtwo et Pikachu ont les mêmes
/// probabilités par rareté, seul le pool de cartes change. C'est ce
/// pool qui fait la différence entre deux boosters d'un même set
/// (voir `BoosterExpectedValue`).
class SetPullRates extends Equatable {
  const SetPullRates({required this.setId, required this.variants});

  /// Identifiant du set, le même que `CardSet.id`.
  final String setId;

  final List<PackVariantPullRates> variants;

  @override
  List<Object?> get props => [setId, variants];
}
