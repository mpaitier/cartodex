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

  /// Une clé de série "classique" : une seule lettre majuscule
  /// ("A", "B", "C"...). Toute autre clé de `sets.json` (ex: "SP")
  /// est considérée comme hors série.
  static final RegExp _mainSeriesKeyPattern = RegExp(r'^[A-Z]$');

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
  /// (voir `SeriesFilterBar`). Aucune liste de séries n'est codée en
  /// dur : une nouvelle clé (ex: "C") apparaît d'elle-même après une
  /// synchronisation.
  final String seriesId;

  /// Url du logo du set (sans extension, ajoutée par
  /// `CardSetGridItem`), reconstruite depuis pocketcards.net à
  /// partir du nom du set — voir `CardSetModel.fromJson`. Ne reste
  /// `null` que pour un set relu depuis une base locale antérieure
  /// à ce champ, ou en l'absence de nom exploitable.
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

  /// Vrai pour un set d'une série principale : clé de série d'une
  /// seule lettre, et code de la forme "<lettre de la série><numéro>"
  /// avec un suffixe minuscule optionnel (ex: "A1", "A1a", "B2b",
  /// "C1").
  ///
  /// Le code doit commencer par la lettre de sa propre série : un
  /// set rangé sous "A" mais codé autrement est traité comme hors
  /// série plutôt que mélangé aux sets de A.
  bool get isMainSeries {
    if (!_mainSeriesKeyPattern.hasMatch(seriesId)) return false;
    return RegExp('^$seriesId\\d+[a-z]?\$').hasMatch(id);
  }

  /// Vrai pour tout ce qui n'est pas un set de série principale :
  /// les promos ("PROMO-A", "PROMO-B", "PROMO-C"...) mais aussi tout
  /// set au code ou à la série inhabituels (ex: "SP"). Ces sets sont
  /// regroupés dans l'onglet "Promo" et exclus des recommandations
  /// de boosters (voir `GetCollectionStats`).
  ///
  /// Dérivé de [id] et [seriesId] plutôt que stocké séparément : pure
  /// fonction de l'identifiant, pas une donnée indépendante à
  /// synchroniser.
  bool get isPromo => !isMainSeries;

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