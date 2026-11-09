import 'package:equatable/equatable.dart';

/// Probabilités d'un emplacement ("slot") d'un booster : pour chaque
/// code de rareté brut ("C", "U", "SR"...), la probabilité que la
/// carte de cet emplacement soit de cette rareté.
///
/// Les probabilités sont des fractions entre 0 et 1 (la source les
/// donne en pourcentage, converties par la couche data). Leur somme
/// vaut 1 aux arrondis près.
///
/// Les codes restent ceux de la source, sans normalisation : c'est
/// `PullRateRarity` qui sait que "SAR" se tire comme "SR", ou qu'une
/// variante brillante ("CF") donne une carte "C".
class SlotPullRates extends Equatable {
  const SlotPullRates(this.rateByRarity);

  final Map<String, double> rateByRarity;

  @override
  List<Object?> get props => [rateByRarity];
}
