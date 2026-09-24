import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/card_set.dart';
import '../../domain/entities/pokemon_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local/card_local_data_source.dart';
import '../datasources/remote/card_remote_data_source.dart';
import '../models/card_set_model.dart';

/// Implémentation de [CardRepository].
///
/// Répartit clairement les responsabilités : la synchronisation
/// s'appuie sur le datasource distant puis écrit dans le
/// datasource local ; toute lecture du catalogue et toute la
/// gestion de la possession ne passent que par le datasource
/// local, jamais par le réseau.
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({
    required CardRemoteDataSource remoteDataSource,
    required CardLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  final CardRemoteDataSource _remoteDataSource;
  final CardLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, void>> syncCardCatalog() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Aucune connexion réseau.'));
    }
    try {
      final sets = await _remoteDataSource.fetchCardSets();

      // Le référentiel distant renvoie toutes les cartes en un seul
      // fichier (voir CardRemoteDataSource) : on les répartit par set
      // ici, sans appel réseau supplémentaire, et on en profite pour
      // renseigner le nom du set (absent de cards.json).
      final allCards = await _remoteDataSource.fetchAllCards();

      // Le total déclaré par la source (`sets.json`) peut manquer
      // (ex: "Promo B" n'a pas de champ `count`) ou diverger du réel :
      // le nombre de cartes effectivement récupérées fait foi. Les
      // sets ne sont donc mis en cache qu'une fois ce total corrigé,
      // pas avec la valeur brute de la source.
      final correctedSets = <CardSetModel>[];
      for (final set in sets) {
        final cardsForSet = allCards
            .where((card) => card.setId == set.id)
            .map((card) => card.copyWith(setName: set.name))
            .toList();
        await _localDataSource.cacheCards(set.id, cardsForSet);
        correctedSets.add(
          CardSetModel(
            id: set.id,
            name: set.name,
            totalCardCount: cardsForSet.length,
            seriesId: set.seriesId,
            logoUrl: set.logoUrl,
            officialCardCount: set.officialCardCount,
            packs: set.packs,
          ),
        );
      }
      await _localDataSource.cacheCardSets(correctedSets);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CardSet>>> getCardSets() async {
    try {
      final sets = await _localDataSource.getCachedCardSets();
      return Right(sets);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PokemonCard>>> getCardsBySet(
    String setId,
  ) async {
    try {
      final cards = await _localDataSource.getCachedCardsBySet(setId);
      return Right(cards);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getOwnedCardIds(String accountId) async {
    try {
      final ids = await _localDataSource.getOwnedCardIds(accountId);
      return Right(ids);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setCardOwned({
    required String cardId,
    required String accountId,
    required bool owned,
  }) async {
    try {
      await _localDataSource.setCardOwned(
        cardId: cardId,
        accountId: accountId,
        owned: owned,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}