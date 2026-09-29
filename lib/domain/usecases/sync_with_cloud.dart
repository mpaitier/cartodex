import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/cloud_account.dart';
import '../entities/sync_result.dart';
import '../repositories/account_repository.dart';
import '../repositories/card_repository.dart';
import '../repositories/cloud_sync_repository.dart';
import '../usecase.dart';

/// Synchronise les comptes Pokémon et leur possession avec le
/// cloud, pour l'utilisateur connecté [SyncWithCloudParams.userId].
///
/// Règle de fusion : "possédée" l'emporte toujours sur "non
/// possédée" — une carte marquée possédée d'un côté (local ou
/// cloud) l'est aussi de l'autre après synchronisation, jamais
/// l'inverse. Aucune carte n'est jamais démarquée par une synchro.
///
/// Déroulé :
/// 1. Remplace les identifiants de compte hérités (simples nombres
///    en texte, d'avant la synchronisation) par de vrais UUID —
///    voir `AccountRepository.migrateLegacyAccountIds`.
/// 2. Compare chaque compte local à son équivalent cloud (par id) :
///    envoie les cartes possédées localement mais pas dans le
///    cloud, récupère celles possédées dans le cloud mais pas en
///    local.
/// 3. Importe en local les comptes qui n'existent que dans le
///    cloud (ex: créés depuis un autre appareil).
///
/// Tout ou rien à la première erreur rencontrée : la synchronisation
/// s'arrête et remonte l'échec, sans revenir en arrière sur ce qui a
/// déjà été appliqué — la fusion étant idempotente, une
/// resynchronisation ultérieure rattrape ce qui manque encore.
class SyncWithCloud implements UseCase<SyncResult, SyncWithCloudParams> {
  const SyncWithCloud({
    required AccountRepository accountRepository,
    required CardRepository cardRepository,
    required CloudSyncRepository cloudSyncRepository,
  })  : _accountRepository = accountRepository,
        _cardRepository = cardRepository,
        _cloudSyncRepository = cloudSyncRepository;

  final AccountRepository _accountRepository;
  final CardRepository _cardRepository;
  final CloudSyncRepository _cloudSyncRepository;

  @override
  Future<Either<Failure, SyncResult>> call(SyncWithCloudParams params) async {
    final migrateResult = await _accountRepository.migrateLegacyAccountIds();
    final migrateFailure = migrateResult.fold((f) => f, (_) => null);
    if (migrateFailure != null) return Left(migrateFailure);

    final localAccountsResult = await _accountRepository.getAccounts();
    final localAccountsFailure = localAccountsResult.fold((f) => f, (_) => null);
    if (localAccountsFailure != null) return Left(localAccountsFailure);
    final localAccounts = localAccountsResult.getOrElse(() => const []);

    // Reconstitue chaque compte local sous la forme "cloud" (avec sa
    // possession), pour pouvoir le comparer terme à terme à son
    // équivalent distant plus bas.
    final localCloudAccounts = <CloudAccount>[];
    for (final account in localAccounts) {
      final ownedResult = await _cardRepository.getOwnedCardIds(account.id);
      final ownedFailure = ownedResult.fold((f) => f, (_) => null);
      if (ownedFailure != null) return Left(ownedFailure);
      localCloudAccounts.add(
        CloudAccount(
          id: account.id,
          name: account.name,
          gameAccountId: account.gameAccountId,
          isPrimary: account.isPrimary,
          createdAt: account.createdAt,
          ownedCardIds: ownedResult.getOrElse(() => const {}),
        ),
      );
    }

    final cloudAccountsResult =
        await _cloudSyncRepository.fetchAccounts(params.userId);
    final cloudAccountsFailure =
        cloudAccountsResult.fold((f) => f, (_) => null);
    if (cloudAccountsFailure != null) return Left(cloudAccountsFailure);
    final cloudAccounts = cloudAccountsResult.getOrElse(() => const []);
    final cloudById = {for (final a in cloudAccounts) a.id: a};
    final localIds = localCloudAccounts.map((a) => a.id).toSet();

    var accountsPulled = 0;
    var accountsPushed = 0;
    var cardsPulled = 0;
    var cardsPushed = 0;

    // Comptes existant localement : on complète le cloud avec ce
    // qui lui manque, puis le local avec ce qui manque ici.
    for (final local in localCloudAccounts) {
      final cloud = cloudById[local.id];
      final cloudOwnedIds = cloud?.ownedCardIds ?? const <String>{};
      final missingInCloud = local.ownedCardIds.difference(cloudOwnedIds);
      final missingInLocal = cloudOwnedIds.difference(local.ownedCardIds);

      if (cloud == null || missingInCloud.isNotEmpty) {
        final pushResult = await _cloudSyncRepository.pushAccount(
          userId: params.userId,
          account: CloudAccount(
            id: local.id,
            name: local.name,
            gameAccountId: local.gameAccountId,
            isPrimary: local.isPrimary,
            createdAt: local.createdAt,
            // Seulement la différence : arrayUnion côté Firestore
            // se charge de l'union, pas la peine de renvoyer ce qui
            // y est déjà.
            ownedCardIds: missingInCloud,
          ),
        );
        final pushFailure = pushResult.fold((f) => f, (_) => null);
        if (pushFailure != null) return Left(pushFailure);
        if (cloud == null) accountsPushed++;
        cardsPushed += missingInCloud.length;
      }

      if (missingInLocal.isNotEmpty) {
        final addResult = await _cardRepository.addOwnedCards(
          accountId: local.id,
          cardIds: missingInLocal,
        );
        final addFailure = addResult.fold((f) => f, (_) => null);
        if (addFailure != null) return Left(addFailure);
        cardsPulled += missingInLocal.length;
      }
    }

    // Comptes qui n'existent que dans le cloud (créés depuis un
    // autre appareil) : importés en entier.
    for (final cloud in cloudAccounts) {
      if (localIds.contains(cloud.id)) continue;
      final importResult = await _accountRepository.importAccount(
        id: cloud.id,
        name: cloud.name,
        gameAccountId: cloud.gameAccountId,
        createdAt: cloud.createdAt,
      );
      final importFailure = importResult.fold((f) => f, (_) => null);
      if (importFailure != null) return Left(importFailure);

      if (cloud.ownedCardIds.isNotEmpty) {
        final addResult = await _cardRepository.addOwnedCards(
          accountId: cloud.id,
          cardIds: cloud.ownedCardIds,
        );
        final addFailure = addResult.fold((f) => f, (_) => null);
        if (addFailure != null) return Left(addFailure);
      }
      accountsPulled++;
      cardsPulled += cloud.ownedCardIds.length;
    }

    return Right(
      SyncResult(
        accountsPulled: accountsPulled,
        accountsPushed: accountsPushed,
        cardsPulled: cardsPulled,
        cardsPushed: cardsPushed,
      ),
    );
  }
}

/// Paramètre attendu par [SyncWithCloud].
class SyncWithCloudParams extends Equatable {
  const SyncWithCloudParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}