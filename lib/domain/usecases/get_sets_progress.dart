import 'package:dartz/dartz.dart';

import '../../core/constants/card_rarities.dart';
import '../../core/error/failures.dart';
import '../entities/account.dart';
import '../entities/pokemon_card.dart';
import '../entities/set_progress.dart';
import '../repositories/account_repository.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Calcule la progression de chaque set synchronisé, indexée par
/// identifiant de set (voir [SetProgress]).
///
/// La progression du compte principal est séparée de celle des
/// comptes secondaires : ces derniers n'apportent que les cartes
/// que le principal n'a pas, sans double-comptage. Le découpage
/// losange / alternatif suit [CardRarity.isBase], comme le détail
/// d'un set, pour que les deux écrans affichent les mêmes chiffres.
///
/// Sans compte principal, la table renvoyée est vide : il n'y a
/// aucune progression à afficher.
class GetSetsProgress implements UseCase<Map<String, SetProgress>, NoParams> {
  const GetSetsProgress({
    required CardRepository cardRepository,
    required AccountRepository accountRepository,
  })  : _cardRepository = cardRepository,
        _accountRepository = accountRepository;

  final CardRepository _cardRepository;
  final AccountRepository _accountRepository;

  @override
  Future<Either<Failure, Map<String, SetProgress>>> call(
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
    if (primary == null) return const Right(<String, SetProgress>{});

    final primaryResult = await _cardRepository.getOwnedCardIds(primary.id);
    final primaryFailure = primaryResult.fold((f) => f, (_) => null);
    if (primaryFailure != null) return Left(primaryFailure);
    final primaryIds = primaryResult.getOrElse(() => const <String>{});

    final secondaryIds = <String>{};
    for (final account in accounts) {
      if (account.isPrimary) continue;
      final ownedResult = await _cardRepository.getOwnedCardIds(account.id);
      final ownedFailure = ownedResult.fold((f) => f, (_) => null);
      if (ownedFailure != null) return Left(ownedFailure);
      secondaryIds.addAll(ownedResult.getOrElse(() => const <String>{}));
    }

    final setsResult = await _cardRepository.getCardSets();
    final setsFailure = setsResult.fold((f) => f, (_) => null);
    if (setsFailure != null) return Left(setsFailure);
    final sets = setsResult.getOrElse(() => const []);

    final progressBySetId = <String, SetProgress>{};
    for (final set in sets) {
      final cardsResult = await _cardRepository.getCardsBySet(set.id);
      final cardsFailure = cardsResult.fold((f) => f, (_) => null);
      if (cardsFailure != null) return Left(cardsFailure);
      progressBySetId[set.id] = _buildProgress(
        setId: set.id,
        cards: cardsResult.getOrElse(() => const <PokemonCard>[]),
        primaryIds: primaryIds,
        secondaryIds: secondaryIds,
      );
    }
    return Right(progressBySetId);
  }

  SetProgress _buildProgress({
    required String setId,
    required List<PokemonCard> cards,
    required Set<String> primaryIds,
    required Set<String> secondaryIds,
  }) {
    var baseTotal = 0;
    var basePrimary = 0;
    var baseAll = 0;
    var alternativeTotal = 0;
    var alternativePrimary = 0;
    var alternativeAll = 0;

    for (final card in cards) {
      final byPrimary = primaryIds.contains(card.id);
      final byAnyAccount = byPrimary || secondaryIds.contains(card.id);
      if (CardRarity.isBase(card.rarity)) {
        baseTotal++;
        if (byPrimary) basePrimary++;
        if (byAnyAccount) baseAll++;
      } else {
        alternativeTotal++;
        if (byPrimary) alternativePrimary++;
        if (byAnyAccount) alternativeAll++;
      }
    }

    return SetProgress(
      setId: setId,
      base: RarityGroupProgress(
        primaryOwned: basePrimary,
        allAccountsOwned: baseAll,
        total: baseTotal,
      ),
      alternative: RarityGroupProgress(
        primaryOwned: alternativePrimary,
        allAccountsOwned: alternativeAll,
        total: alternativeTotal,
      ),
    );
  }
}