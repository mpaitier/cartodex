import 'package:equatable/equatable.dart';

/// Progression sur un groupe de cartes d'un set (les losanges, ou
/// tout le reste), pour le compte principal et pour l'ensemble des
/// comptes.
///
/// [allAccountsOwned] est une union : une carte possédée par le
/// principal et par un secondaire n'est comptée qu'une fois. Il ne
/// dépasse donc jamais [total], et [primaryOwned] n'est jamais
/// supérieur à [allAccountsOwned].
class RarityGroupProgress extends Equatable {
  const RarityGroupProgress({
    required this.primaryOwned,
    required this.allAccountsOwned,
    required this.total,
  });

  /// Cartes du groupe possédées par le compte principal.
  final int primaryOwned;

  /// Cartes du groupe possédées par le principal ou par au moins un
  /// compte secondaire.
  final int allAccountsOwned;

  final int total;

  /// Cartes possédées par un secondaire mais pas par le principal :
  /// ce que les comptes secondaires ajoutent à la progression.
  int get secondaryExtraOwned => allAccountsOwned - primaryOwned;

  /// Vrai quand le set n'a aucune carte dans ce groupe (ex: un set
  /// promo sans carte losange).
  bool get isEmpty => total == 0;

  /// Vrai quand le compte principal, à lui seul, possède tout le
  /// groupe. Posséder l'ensemble via les secondaires ne compte pas.
  bool get isPrimaryComplete => total > 0 && primaryOwned >= total;

  double get primaryRatio => total == 0 ? 0 : primaryOwned / total;

  double get secondaryExtraRatio =>
      total == 0 ? 0 : secondaryExtraOwned / total;

  @override
  List<Object?> get props => [primaryOwned, allAccountsOwned, total];
}

/// Progression d'un set, découpée comme dans le détail d'un set :
/// la collection de base (cartes losange) d'un côté, les cartes
/// alternatives (étoile, couronne, chromatique, ou sans rareté
/// connue) de l'autre.
class SetProgress extends Equatable {
  const SetProgress({
    required this.setId,
    required this.base,
    required this.alternative,
  });

  final String setId;
  final RarityGroupProgress base;
  final RarityGroupProgress alternative;

  @override
  List<Object?> get props => [setId, base, alternative];
}