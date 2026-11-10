import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/card_model.dart';
import '../../models/card_set_model.dart';
import '../../models/set_pull_rates_model.dart';

/// Accès au référentiel distant de cartes.
///
/// Ne connaît rien de la possession des cartes : c'est strictement
/// le catalogue distant, tel que décrit dans le README.
///
/// S'appuie sur `pokemon-tcg-pocket-database`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database),
/// des fichiers JSON statiques servis par jsDelivr, plutôt que sur
/// TCGdex : ce dernier ne modélisait pas la répartition des cartes
/// par booster à l'intérieur d'un set, une donnée que ce jeu-ci
/// fournit nativement (`sets.json.packs`, `packs` de chaque carte).
/// Trois requêtes suffisent à tout récupérer : `sets.json`,
/// `cards.extra.json` (toutes les cartes, avec type, élément et PV)
/// et `pullRates.json` (probabilités de tirage des boosters).
abstract class CardRemoteDataSource {
  /// Récupère tous les sets TCG Pocket, tous groupes de série
  /// confondus.
  Future<List<CardSetModel>> fetchCardSets();

  /// Récupère l'intégralité des cartes, tous sets confondus. Le
  /// tri par set est fait par l'appelant (voir
  /// `CardRepositoryImpl.syncCardCatalog`), qui a besoin des deux
  /// listes de toute façon pour associer chaque carte au nom de
  /// son set.
  Future<List<CardModel>> fetchAllCards();

  /// Récupère les probabilités de tirage des boosters, un élément par
  /// set présent dans `pullRates.json`.
  Future<List<SetPullRatesModel>> fetchPullRates();
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  const CardRemoteDataSourceImpl(this._client);

  final http.Client _client;

  @override
  Future<List<CardSetModel>> fetchCardSets() async {
    final uri = Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/sets.json');
    final response = await _get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    // sets.json groupe les sets par série ({"A": [...], "B": [...]}) :
    // on aplatit pour l'affichage, mais en gardant la clé de groupe
    // (voir CardSetModel.seriesId) pour le filtre par série.
    return body.entries.expand((entry) {
      final seriesId = entry.key;
      final sets = (entry.value as List<dynamic>).cast<Map<String, dynamic>>();
      return sets.map((json) => CardSetModel.fromJson(json, seriesId: seriesId));
    }).toList();
  }

  /// Lit les cartes dans `cards.extra.json`, pris sur le dépôt GitHub
  /// du référentiel (voir [AppConstants.pocketDatabaseGithubBaseUrl]).
  /// Ce fichier contient tous les champs de `cards.json` (set, numéro,
  /// nom, rareté, boosters) et en ajoute d'autres : le type de carte,
  /// l'élément et les PV. Un seul fichier suffit donc.
  ///
  /// En cas d'échec sur GitHub, repli sur la version npm : là, le
  /// `cards.extra.json` publié ne couvre pas toutes les extensions,
  /// donc la liste des cartes vient de `cards.json`, complétée par
  /// `cards.extra.json` quand une carte y figure. Seul un échec des
  /// deux sources fait échouer la synchronisation.
  ///
  /// Le même repli s'applique quand le fichier GitHub n'a plus le
  /// format plat attendu (voir [_isFlatCardList]). La branche `main`
  /// suit le dépôt au fil de l'eau, elle recevra donc une éventuelle
  /// version majeure avant npm.
  @override
  Future<List<CardModel>> fetchAllCards() async {
    final githubUri = Uri.parse(
      '${AppConstants.pocketDatabaseGithubBaseUrl}/cards.extra.json',
    );
    try {
      final decoded = jsonDecode((await _get(githubUri)).body);
      if (decoded is List<dynamic> && _isFlatCardList(decoded)) {
        return decoded
            .cast<Map<String, dynamic>>()
            .map((raw) => _cardFromExtra(raw, raw))
            .toList();
      }
      AppLogger.log(
        'WARNING',
        'cards.extra.json au format inattendu sur GitHub '
            '(nouvelle version majeure ?), repli sur npm.',
      );
    } on Exception catch (e) {
      AppLogger.log(
        'WARNING',
        'cards.extra.json indisponible sur GitHub, repli sur npm : $e',
      );
    }
    return _fetchAllCardsFromNpm();
  }

  /// Vrai si [cards] suit le format plat de la version 2 du
  /// référentiel : une entrée par impression, avec `set` (texte) et
  /// `number` (nombre) à la racine. [CardModel.fromJson] lit ces deux
  /// champs sans contrôle ; une valeur absente y lèverait une
  /// `TypeError`, qui n'est pas une `Exception` et échapperait donc au
  /// repli de [fetchAllCards]. La version 3 envisagée regroupe les
  /// réimpressions sous un tableau `sets`, sans `set` à la racine :
  /// ce contrôle la détecte et bascule sur npm, figé en 2.x.
  static bool _isFlatCardList(List<dynamic> cards) {
    return cards.isNotEmpty &&
        cards.every(
          (raw) =>
              raw is Map<String, dynamic> &&
              raw['set'] is String &&
              raw['number'] is num,
        );
  }

  /// Repli de [fetchAllCards] sur la version npm : `cards.json` pour la
  /// liste complète des cartes, croisé par set et numéro avec
  /// `cards.extra.json` (sans jointure O(n²)) pour le type, l'élément
  /// et les PV des cartes qui y figurent.
  Future<List<CardModel>> _fetchAllCardsFromNpm() async {
    final cardsUri =
        Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/cards.json');
    final extraUri =
        Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/cards.extra.json');
    final cardsBody = jsonDecode((await _get(cardsUri)).body) as List<dynamic>;
    final extraBody = jsonDecode((await _get(extraUri)).body) as List<dynamic>;

    final extraByKey = <String, Map<String, dynamic>>{
      for (final raw in extraBody.cast<Map<String, dynamic>>())
        '${raw['set']}-${raw['number']}': raw,
    };

    return cardsBody.cast<Map<String, dynamic>>().map((raw) {
      final extra = extraByKey['${raw['set']}-${raw['number']}'];
      return _cardFromExtra(raw, extra);
    }).toList();
  }

  /// Carte construite à partir de ses champs de base ([base] : set,
  /// numéro, nom, rareté, boosters) et de ses détails ([extra] : type,
  /// élément, PV), qui viennent de la même entrée quand on lit
  /// `cards.extra.json` seul. [extra] à `null` laisse ces détails vides.
  static CardModel _cardFromExtra(
    Map<String, dynamic> base,
    Map<String, dynamic>? extra,
  ) {
    return CardModel.fromJson(
      base,
      category: extra?['type'] as String?,
      element: extra?['element'] as String?,
      hp: (extra?['health'] as num?)?.toInt(),
    );
  }

  @override
  Future<List<SetPullRatesModel>> fetchPullRates() async {
    final uri =
        Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/pullRates.json');
    final body = jsonDecode((await _get(uri)).body) as Map<String, dynamic>;
    return [
      for (final entry in body.entries)
        if (entry.value is Map<String, dynamic>)
          SetPullRatesModel.fromJson(
            entry.key,
            entry.value as Map<String, dynamic>,
          ),
    ];
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
          'Le référentiel de cartes a répondu ${response.statusCode} pour $uri.',
        );
      }
      return response;
    } on ServerException {
      rethrow;
    } on Exception {
      throw const ServerException();
    }
  }
}