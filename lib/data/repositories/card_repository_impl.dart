import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/card_set.dart';
import '../../domain/entities/pokemon_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local/card_local_data_source.dart';
import '../datasources/remote/card_remote_data_source.dart';

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
      await _localDataSource.cacheCardSets(sets);
      for (final set in sets) {
        final cards = await _remoteDataSource.fetchCardsBySet(set.id);
        await _localDataSource.cacheCards(set.id, cards);
      }
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
  Future<Either<Failure, Set<String>>> getOwnedCardIds() async {
    try {
      final ids = await _localDataSource.getOwnedCardIds();
      return Right(ids);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setCardOwned(
    String cardId,
    bool owned,
  ) async {
    try {
      await _localDataSource.setCardOwned(cardId, owned);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}