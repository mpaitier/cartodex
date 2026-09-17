import 'package:equatable/equatable.dart';

/// Représente un set de cartes (ex: "Genetic Apex") tel que
/// synchronisé depuis TCGdex.
///
/// Ne contient aucune information de possession : c'est un pur
/// référentiel, à l'image de la séparation décrite dans le README
/// entre catalogue distant et collection locale.
class CardSet extends Equatable {
  const CardSet({
    required this.id,
    required this.name,
    required this.totalCardCount,
    this.logoUrl,
    this.officialCardCount,
  });

  /// Identifiant TCGdex du set (ex: "A1").
  final String id;

  final String name;

  /// Nombre total de cartes du set, variantes comprises.
  final int totalCardCount;

  /// Url du logo du set, fournie par TCGdex. Peut être absente pour
  /// certains sets promotionnels.
  final String? logoUrl;

  /// Nombre de cartes "officielles" du set (hors variantes), quand
  /// TCGdex la fournit.
  final int? officialCardCount;

  @override
  List<Object?> get props => [
        id,
        name,
        totalCardCount,
        logoUrl,
        officialCardCount,
      ];
}