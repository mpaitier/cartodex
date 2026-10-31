import 'package:equatable/equatable.dart';

import 'set_category.dart';

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

  /// Marqueur cherché dans le nom anglais du set pour reconnaître un
  /// booster Deluxe (ex: "Deluxe Pack: ex", "Deluxe Pack: Mega").
  /// Comparé en minuscules, pour ne pas dépendre de la casse exacte
  /// choisie par la source.
  static const String _deluxeNameMarker = 'deluxe pack';

  /// Identifiant du set (ex: "A1").
  final String id;

  /// Nom anglais du set (voir `CardSetModel.fromJson`).
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

  /// Vrai quand le code et la clé de série ont la forme d'un set de
  /// série principale : clé d'une seule lettre, et code de la forme
  /// "<lettre de la série><numéro>" avec un suffixe minuscule
  /// optionnel (ex: "A1", "A1a", "B2b", "C1").
  ///
  /// Le code doit commencer par la lettre de sa propre série : un
  /// set rangé sous "A" mais codé autrement est traité comme hors
  /// série plutôt que mélangé aux sets de A.
  ///
  /// Ne regarde que la forme du code : un booster Deluxe comme "A4b"
  /// répond vrai ici, c'est [category] qui le sort de sa série.
  bool get isMainSeries {
    if (!_mainSeriesKeyPattern.hasMatch(seriesId)) return false;
    return RegExp('^$seriesId\\d+[a-z]?\$').hasMatch(id);
  }

  /// Vrai pour un booster Deluxe : son nom anglais contient "Deluxe
  /// Pack".
  bool get isDeluxe => name.toLowerCase().contains(_deluxeNameMarker);

  /// Famille du set (voir [SetCategory]). Deluxe passe en premier :
  /// un booster Deluxe a souvent un code de série principale ("A4b",
  /// "B4b") mais doit rester dans sa propre section.
  ///
  /// Dérivée de [id], [seriesId] et [name] plutôt que stockée
  /// séparément : pure fonction des données du set, pas une donnée
  /// indépendante à synchroniser.
  SetCategory get category {
    if (isDeluxe) return SetCategory.deluxe;
    if (isMainSeries) return SetCategory.main;
    return SetCategory.promo;
  }

  /// Vrai pour tout ce qui n'est ni un set de série principale ni un
  /// booster Deluxe : les promos ("PROMO-A", "PROMO-B"...) mais aussi
  /// tout set au code ou à la série inhabituels (ex: "SP"). Ces sets
  /// sont regroupés dans l'onglet "Promo" et exclus des
  /// recommandations de boosters (voir `GetCollectionStats`).
  bool get isPromo => category == SetCategory.promo;

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