import 'package:equatable/equatable.dart';

import 'slot_pull_rates.dart';

/// Une variante de booster et ses probabilités, telles que publiées
/// pour un set : booster normal ("Regular Pack"), booster rare ("Rare
/// Pack", toutes les cartes étoile ou mieux), booster à 6 cartes
/// ("Regular Pack +1")...
///
/// Le joueur ne choisit pas la variante : à l'ouverture, le jeu tire
/// l'une d'elles selon [appearanceRate], puis chaque emplacement
/// ([slots]) selon ses propres probabilités.
class PackVariantPullRates extends Equatable {
  const PackVariantPullRates({
    required this.name,
    required this.appearanceRate,
    required this.slots,
  });

  /// Nom de la variante dans la source (ex: "Regular Pack").
  final String name;

  /// Probabilité que cette variante sorte à l'ouverture, entre 0
  /// et 1.
  final double appearanceRate;

  /// Un élément par carte du booster, dans l'ordre d'ouverture.
  final List<SlotPullRates> slots;

  @override
  List<Object?> get props => [name, appearanceRate, slots];
}
