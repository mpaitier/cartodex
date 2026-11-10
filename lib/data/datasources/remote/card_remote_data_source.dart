import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
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
/// trois fichiers JSON statiques servis par jsDelivr, plutôt que
/// sur TCGdex : ce dernier ne modélisait pas la répartition des
/// cartes par booster à l'intérieur d'un set, une donnée que ce
/// jeu-ci fournit nativement (`sets.json.packs`,
/// `cards.json.packs`). Trois requêtes suffisent à tout récupérer,
/// contre une par carte auparavant, plus une quatrième pour les
/// probabilités de tirage des boosters (`pullRates.json`).
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

  @override
  Future<List<CardModel>> fetchAllCards() async {
    final cardsUri = Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/cards.json');
    final extraUri =
        Uri.parse('${AppConstants.pocketDatabaseBaseUrl}/cards.extra.json');
    final cardsBody = jsonDecode((await _get(cardsUri)).body) as List<dynamic>;
    final extraBody = jsonDecode((await _get(extraUri)).body) as List<dynamic>;

    // cards.json ne porte ni la catégorie (Pokémon / Dresseur / Énergie)
    // ni l'élément (Plante, Feu...) ; seul cards.extra.json les a, sous
    // les champs `type` et `element`. On construit un index set-numéro ->
    // carte enrichie pour croiser les deux sans jointure O(n²).
    final extraByKey = <String, Map<String, dynamic>>{
      for (final raw in extraBody.cast<Map<String, dynamic>>())
        '${raw['set']}-${raw['number']}': raw,
    };

    return cardsBody.cast<Map<String, dynamic>>().map((raw) {
      final extra = extraByKey['${raw['set']}-${raw['number']}'];
      return CardModel.fromJson(
        raw,
        category: extra?['type'] as String?,
        element: extra?['element'] as String?,
      );
    }).toList();
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