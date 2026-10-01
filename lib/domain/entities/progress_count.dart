import 'package:equatable/equatable.dart';

/// Compteur de progression "X (+Y) / Z", partagé par toutes les
/// statistiques (global, série, set, booster).
///
/// - [owned] (X) : cartes possédées par le compte principal ;
/// - [secondaryExtra] (Y) : cartes possédées par au moins un compte
///   secondaire mais pas par le principal — comptées une seule fois
///   même si plusieurs secondaires la possèdent, et jamais en double
///   avec [owned] ;
/// - [total] (Z) : cartes existantes.
///
/// [owned] + [secondaryExtra] ne dépasse donc jamais [total].
class ProgressCount extends Equatable {
  const ProgressCount({
    required this.owned,
    required this.secondaryExtra,
    required this.total,
  });

  static const ProgressCount zero =
      ProgressCount(owned: 0, secondaryExtra: 0, total: 0);

  final int owned;
  final int secondaryExtra;
  final int total;

  /// Part du principal, entre 0 et 1.
  double get primaryRatio => total == 0 ? 0 : owned / total;

  /// Part ajoutée par les secondaires, entre 0 et 1.
  double get secondaryExtraRatio => total == 0 ? 0 : secondaryExtra / total;

  /// Vrai quand le compte principal, à lui seul, possède tout. Les
  /// cartes des secondaires ne comptent pas : même règle que la
  /// bordure des tuiles de sets.
  bool get isComplete => total > 0 && owned >= total;

  /// Somme de deux compteurs (agrégation de plusieurs sets, par
  /// exemple).
  ProgressCount operator +(ProgressCount other) {
    return ProgressCount(
      owned: owned + other.owned,
      secondaryExtra: secondaryExtra + other.secondaryExtra,
      total: total + other.total,
    );
  }

  @override
  List<Object?> get props => [owned, secondaryExtra, total];
}