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
/// Les sets de chaque secondaire sont triés par losanges en plus, puis
/// par étoiles en plus, l'ordre du catalogue départageant les égalités
/// (voir [SetExtras.sortedByCounts]) : le détail d'un compte montre
/// d'abord les sets où il apporte le plus.
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
        final setExtras = _setExtras(
          set: set,
          cards: cardsBySetId[set.id] ?? const <PokemonCard>[],
          primaryIds: primaryIds,
          secondaryIds: secondaryIds,
        );
        if (setExtras.counts.isEmpty) continue;
        bySet.add(setExtras);
      }
      extrasByAccountId[account.id] = AccountExtras(
        accountId: account.id,
        bySet: SetExtras.sortedByCounts(bySet),
      );
    }
    return Right(extrasByAccountId);
  }

  /// Cartes en plus du secondaire dans [set], et si elles complètent
  /// le principal, côté losanges et côté étoiles : le principal et
  /// ses cartes en plus couvrent alors tout le groupe (voir
  /// [SetExtras.completesBase]).
  SetExtras _setExtras({
    required CardSet set,
    required List<PokemonCard> cards,
    required Set<String> primaryIds,
    required Set<String> secondaryIds,
  }) {
    var baseTotal = 0;
    var baseOwnedByPrimary = 0;
    var baseExtra = 0;
    var alternativeTotal = 0;
    var alternativeOwnedByPrimary = 0;
    var alternativeExtra = 0;
    for (final card in cards) {
      final ownedByPrimary = primaryIds.contains(card.id);
      final extra = !ownedByPrimary && secondaryIds.contains(card.id);
      if (CardRarity.isBase(card.rarity)) {
        baseTotal++;
        if (ownedByPrimary) baseOwnedByPrimary++;
        if (extra) baseExtra++;
      } else {
        alternativeTotal++;
        if (ownedByPrimary) alternativeOwnedByPrimary++;
        if (extra) alternativeExtra++;
      }
    }
    return SetExtras(
      set: set,
      counts: ExtraCounts(base: baseExtra, alternative: alternativeExtra),
      completesBase:
          baseExtra > 0 && baseOwnedByPrimary + baseExtra == baseTotal,
      completesAlternative: alternativeExtra > 0 &&
          alternativeOwnedByPrimary + alternativeExtra == alternativeTotal,
    );
  }
}