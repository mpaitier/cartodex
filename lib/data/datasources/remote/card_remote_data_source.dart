import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/card_model.dart';
import '../../models/card_set_model.dart';

/// Accès à l'API TCGdex pour le référentiel de cartes.
///
/// Ne connaît rien de la possession des cartes : c'est strictement
/// le catalogue distant, tel que décrit dans le README.
abstract class CardRemoteDataSource {
  /// Récupère tous les sets de la série TCG Pocket.
  Future<List<CardSetModel>> fetchCardSets();

  /// Récupère toutes les cartes d'un set, avec leur détail complet
  /// (catégorie, rareté, HP, types...).
  Future<List<CardModel>> fetchCardsBySet(String setId);
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  const CardRemoteDataSourceImpl(this._client);

  final http.Client _client;

  /// Nombre de cartes détaillées récupérées en parallèle.
  ///
  /// `GET /sets/{id}` ne renvoie que des références légères (id,
  /// image, localId, name) : pour obtenir catégorie, rareté, HP et
  /// types, il faut rappeler `GET /cards/{id}` carte par carte. On
  /// limite le parallélisme pour rester raisonnable vis-à-vis de
  /// l'API plutôt que de tirer toutes les requêtes d'un coup.
  static const int _detailBatchSize = 10;

  @override
  Future<List<CardSetModel>> fetchCardSets() async {
    final uri = Uri.parse(
      '${AppConstants.tcgdexBaseUrl}/en/series/${AppConstants.tcgPocketSeriesId}',
    );
    final response = await _get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final sets = (body['sets'] as List<dynamic>?) ?? const [];
    return sets
        .cast<Map<String, dynamic>>()
        .map(CardSetModel.fromJson)
        .toList();
  }

  @override
  Future<List<CardModel>> fetchCardsBySet(String setId) async {
    final setUri = Uri.parse('${AppConstants.tcgdexBaseUrl}/en/sets/$setId');
    final setResponse = await _get(setUri);
    final setBody = jsonDecode(setResponse.body) as Map<String, dynamic>;
    final briefCards = (setBody['cards'] as List<dynamic>?) ?? const [];
    final cardIds = briefCards
        .cast<Map<String, dynamic>>()
        .map((json) => json['id'] as String)
        .toList();

    final cards = <CardModel>[];
    for (var i = 0; i < cardIds.length; i += _detailBatchSize) {
      final batch = cardIds.skip(i).take(_detailBatchSize);
      final batchResults = await Future.wait(batch.map(_fetchCardDetail));
      cards.addAll(batchResults);
    }
    return cards;
  }

  Future<CardModel> _fetchCardDetail(String cardId) async {
    final uri = Uri.parse('${AppConstants.tcgdexBaseUrl}/en/cards/$cardId');
    final response = await _get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return CardModel.fromJson(body);
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
          'TCGdex a répondu ${response.statusCode} pour $uri.',
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