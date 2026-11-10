import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/account.dart';
import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:cartodex/domain/entities/set_pull_rates.dart';
import 'package:cartodex/domain/repositories/account_repository.dart';
import 'package:cartodex/domain/repositories/card_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Référentiel et possession en mémoire, pour tester les use cases de
/// calcul sans base locale. Seules les lectures sont implémentées ;
/// toute autre méthode lève une erreur (voir [Fake]).
class FakeCardRepository extends Fake implements CardRepository {
  FakeCardRepository({
    this.sets = const [],
    this.cardsBySetId = const {},
    this.ownedByAccountId = const {},
    this.pullRates = const [],
  });

  final List<CardSet> sets;
  final Map<String, List<PokemonCard>> cardsBySetId;
  final Map<String, Set<String>> ownedByAccountId;
  final List<SetPullRates> pullRates;

  /// Fait échouer [getOwnedCardIds] pour ce compte.
  String? failingAccountId;

  @override
  Future<Either<Failure, List<CardSet>>> getCardSets() async => Right(sets);

  @override
  Future<Either<Failure, List<PokemonCard>>> getCardsBySet(
    String setId,
  ) async =>
      Right(cardsBySetId[setId] ?? const []);

  @override
  Future<Either<Failure, Set<String>>> getOwnedCardIds(
    String accountId,
  ) async {
    if (accountId == failingAccountId) {
      return const Left(CacheFailure('lecture impossible'));
    }
    return Right(ownedByAccountId[accountId] ?? const {});
  }

  @override
  Future<Either<Failure, List<SetPullRates>>> getPullRates() async =>
      Right(pullRates);
}

/// Comptes en mémoire. [failure] fait échouer [getAccounts].
class FakeAccountRepository extends Fake implements AccountRepository {
  FakeAccountRepository({this.accounts = const [], this.failure});

  final List<Account> accounts;
  final Failure? failure;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    final failure = this.failure;
    if (failure != null) return Left(failure);
    return Right(accounts);
  }
}

Account testAccount(String id, {bool isPrimary = false}) => Account(
      id: id,
      name: id,
      gameAccountId: id,
      isPrimary: isPrimary,
      createdAt: DateTime(2026),
    );

PokemonCard testCard(
  String setId,
  int number,
  String? rarity, {
  List<String> packs = const [],
}) =>
    PokemonCard(
      id: '$setId-$number',
      localId: '$number',
      name: '$setId-$number',
      category: CardCategory.pokemon,
      setId: setId,
      setName: setId,
      rarity: rarity,
      packs: packs,
    );
