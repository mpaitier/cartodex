import 'package:dartz/dartz.dart';

import '../../core/constants/card_rarities.dart';
import '../../core/error/failures.dart';
import '../entities/account.dart';
import '../entities/account_extras.dart';
import '../entities/card_set.dart';
import '../entities/pokemon_card.dart';
import '../repositories/account_repository.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Calcule, pour chaque compte secondaire, les cartes qu'il possède
/// et que le compte principal n'a pas, set par set et séparées entre
/// losanges et étoiles (voir [AccountExtras]).
///
/// La table renvoyée est indexée par identifiant de compte. Chaque
/// secondaire y figure, même sans aucune carte en plus (liste de sets
/// vide). Sans compte principal, la table est vide : il n'y a rien à
/// comparer. Le découpage losange / alternatif suit
/// [CardRarity.isBase], comme le détail d'un set.
///
/// Les cartes de chaque set ne sont lues qu'une fois, puis réutilisées
/// pour tous les secondaires.
class GetSecondaryAccountsExtras
    implements UseCase<Map<String, AccountExtras>, NoParams> {
  const GetSecondaryAccountsExtras({
    required CardRepository cardRepository,
    required AccountRepository accountRepository,
  })  : _cardRepository = cardRepository,
        _accountRepository = accountRepository;

  final CardRepository _cardRepository;
  final AccountRepository _accountRepository;

  @override
  Future<Either<Failure, Map<String, AccountExtras>>> call(
    NoParams params,
  ) async {
    final accountsResult = await _accountRepository.getAccounts();
    final accountsFailure = accountsResult.fold((f) => f, (_) => null);
    if (accountsFailure != null) return Left(accountsFailure);
    final accounts = accountsResult.getOrElse(() => const <Account>[]);

    Account? primary;
    for (final account in accounts) {
      if (account.isPrimary) {
        primary = account;
        break;
      }
    }
    if (primary == null) return const Right(<String, AccountExtras>{});

    final secondaries =
        accounts.where((account) => !account.isPrimary).toList();
    if (secondaries.isEmpty) return const Right(<String, AccountExtras>{});

    final primaryResult = await _cardRepository.getOwnedCardIds(primary.id);
    final primaryFailure = primaryResult.fold((f) => f, (_) => null);
    if (primaryFailure != null) return Left(primaryFailure);
    final primaryIds = primaryResult.getOrElse(() => const <String>{});

    final ownedBySecondaryId = <String, Set<String>>{};
    for (final account in secondaries) {
      final ownedResult = await _cardRepository.getOwnedCardIds(account.id);
      final ownedFailure = ownedResult.fold((f) => f, (_) => null);
      if (ownedFailure != null) return Left(ownedFailure);
      ownedBySecondaryId[account.id] =
          ownedResult.getOrElse(() => const <String>{});
    }

    final setsResult = await _cardRepository.getCardSets();
    final setsFailure = setsResult.fold((f) => f, (_) => null);
    if (setsFailure != null) return Left(setsFailure);
    final sets = setsResult.getOrElse(() => const <CardSet>[]);

    final cardsBySetId = <String, List<PokemonCard>>{};
    for (final set in sets) {
      final cardsResult = await _cardRepository.getCardsBySet(set.id);
      final cardsFailure = cardsResult.fold((f) => f, (_) => null);
      if (cardsFailure != null) return Left(cardsFailure);
      cardsBySetId[set.id] = cardsResult.getOrElse(() => const <PokemonCard>[]);
    }

    final extrasByAccountId = <String, AccountExtras>{};
    for (final account in secondaries) {
      final secondaryIds = ownedBySecondaryId[account.id] ?? const <String>{};
      final bySet = <SetExtras>[];
      for (final set in sets) {
        final counts = _countExtras(
          cards: cardsBySetId[set.id] ?? const <PokemonCard>[],
          primaryIds: primaryIds,
          secondaryIds: secondaryIds,
        );
        if (counts.isEmpty) continue;
        bySet.add(SetExtras(set: set, counts: counts));
      }
      extrasByAccountId[account.id] =
          AccountExtras(accountId: account.id, bySet: bySet);
    }
    return Right(extrasByAccountId);
  }

  ExtraCounts _countExtras({
    required List<PokemonCard> cards,
    required Set<String> primaryIds,
    required Set<String> secondaryIds,
  }) {
    var base = 0;
    var alternative = 0;
    for (final card in cards) {
      final extra =
          secondaryIds.contains(card.id) && !primaryIds.contains(card.id);
      if (!extra) continue;
      if (CardRarity.isBase(card.rarity)) {
        base++;
      } else {
        alternative++;
      }
    }
    return ExtraCounts(base: base, alternative: alternative);
  }
}