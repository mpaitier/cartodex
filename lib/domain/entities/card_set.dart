import 'package:equatable/equatable.dart';

/// Représente un set de cartes (ex: "Genetic Apex") tel que
/// synchronisé depuis le référentiel distant.
///
/// Ne contient aucune information de possession : c'est un pur
/// référentiel, à l'image de la séparation décrite dans le README
/// entre catalogue distant et collection locale.
class CardSet extends Equatable {
  const CardSet({
    required this.id,
    required this.name,
    required this.totalCardCount,
    required this.seriesId,
    this.logoUrl,
    this.officialCardCount,
    this.packs = const [],
  });

  /// Identifiant du set (ex: "A1").
  final String id;

  final String name;

  /// Nombre total de cartes du set, variantes comprises. Calculé à
  /// partir des cartes effectivement synchronisées (voir
  /// `CardRepositoryImpl.syncCardCatalog`) plutôt que lu tel quel
  /// depuis la source : celle-ci peut l'omettre (c'est le cas pour
  /// "Promo B" par exemple) ou diverger du réel.
  final int totalCardCount;

  /// Clé de série de la source (ex: "A", "B") — le regroupement de
  /// haut niveau de `sets.json`, utilisé pour le filtre par série
  /// (voir `SeriesFilterBar`).
  final String seriesId;

  /// Url du logo du set. Le référentiel actuel n'en fournit pas :
  /// reste `null` tant qu'une source d'images n'est pas branchée.
  final String? logoUrl;

  /// Nombre de cartes "officielles" du set (hors variantes), quand
  /// la source la fournit.
  final int? officialCardCount;

  /// Boosters disponibles pour ce set (ex: ["Charizard", "Mewtwo",
  /// "Pikachu"] pour Genetic Apex). C'est cette liste qui manquait
  /// à l'ancien référentiel : dans le jeu, chaque set se décline en
  /// plusieurs boosters distincts, chacun avec son propre pool de
  /// cartes.
  final List<String> packs;

  /// Vrai pour les sets promotionnels (code préfixé "PROMO-", ex:
  /// "PROMO-B"). Dérivé de [id] plutôt que stocké séparément : pure
  /// fonction de l'identifiant, pas une donnée indépendante à
  /// synchroniser.
  bool get isPromo => id.startsWith('PROMO-');

  @override
  List<Object?> get props => [
        id,
        name,
        totalCardCount,
        seriesId,
        logoUrl,
        officialCardCount,
        packs,
      ];
}