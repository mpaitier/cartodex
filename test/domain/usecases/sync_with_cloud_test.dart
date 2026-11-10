import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/account.dart';
import 'package:cartodex/domain/entities/cloud_account.dart';
import 'package:cartodex/domain/entities/sync_quota.dart';
import 'package:cartodex/domain/entities/sync_result.dart';
import 'package:cartodex/domain/repositories/account_repository.dart';
import 'package:cartodex/domain/repositories/card_repository.dart';
import 'package:cartodex/domain/repositories/cloud_sync_repository.dart';
import 'package:cartodex/domain/repositories/user_preferences_repository.dart';
import 'package:cartodex/domain/services/sync_rate_limit.dart';
import 'package:cartodex/domain/usecases/get_sync_quota.dart';
import 'package:cartodex/domain/usecases/sync_with_cloud.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

const _userId = 'user-1';
final _now = DateTime(2026, 11, 10, 12);

/// Aucun compte local : la synchronisation se résume à lire le cloud.
class _FakeAccounts extends Fake implements AccountRepository {
  @override
  Future<Either<Failure, void>> migrateLegacyAccountIds() async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async =>
      const Right([]);
}

class _FakeCards extends Fake implements CardRepository {}

/// Cloud vide. [failing] fait échouer la lecture ; [fetchCount] compte
/// les appels, pour vérifier qu'une synchro refusée ne touche pas au
/// cloud.
class _FakeCloud extends Fake implements CloudSyncRepository {
  bool failing = false;
  int fetchCount = 0;

  @override
  Future<Either<Failure, List<CloudAccount>>> fetchAccounts(
    String userId,
  ) async {
    fetchCount++;
    if (failing) return const Left(ServerFailure('cloud indisponible'));
    return const Right([]);
  }
}

class _FakePreferences extends Fake implements UserPreferencesRepository {
  final Map<String, List<DateTime>> histories = {};

  @override
  Future<Either<Failure, List<DateTime>>> getSyncHistory(
    String userId,
  ) async =>
      Right(histories[userId] ?? const []);

  @override
  Future<Either<Failure, void>> saveSyncHistory(
    String userId,
    List<DateTime> history,
  ) async {
    histories[userId] = history;
    return const Right(null);
  }
}

void main() {
  late _FakeCloud cloud;
  late _FakePreferences preferences;
  late SyncWithCloud syncWithCloud;

  setUp(() {
    cloud = _FakeCloud();
    preferences = _FakePreferences();
    syncWithCloud = SyncWithCloud(
      accountRepository: _FakeAccounts(),
      cardRepository: _FakeCards(),
      cloudSyncRepository: cloud,
      userPreferencesRepository: preferences,
      now: () => _now,
    );
  });

  Future<Either<Failure, SyncResult>> sync() =>
      syncWithCloud(const SyncWithCloudParams(userId: _userId));

  group('SyncWithCloud, limite de synchronisations', () {
    test('une synchro réussie est enregistrée dans l’historique', () async {
      final result = await sync();
      expect(result.isRight(), isTrue);
      expect(preferences.histories[_userId], [_now]);
    });

    test('limite atteinte : refusée sans lire le cloud', () async {
      final oldest = _now.subtract(const Duration(hours: 10));
      preferences.histories[_userId] = [
        oldest,
        _now.subtract(const Duration(hours: 5)),
        _now.subtract(const Duration(hours: 2)),
        _now.subtract(const Duration(hours: 1)),
      ];

      final result = await sync();

      expect(
        result,
        Left<Failure, SyncResult>(
          SyncQuotaExceededFailure(oldest.add(SyncRateLimit.window)),
        ),
      );
      expect(cloud.fetchCount, 0);
    });

    test('une synchro en échec ne consomme pas le quota', () async {
      cloud.failing = true;
      final result = await sync();
      expect(result.isLeft(), isTrue);
      expect(preferences.histories[_userId], isNull);
    });

    test('l’historique enregistré est purgé de ce qui a plus de 24 h',
        () async {
      final recent = _now.subtract(const Duration(hours: 3));
      preferences.histories[_userId] = [
        _now.subtract(const Duration(hours: 30)),
        recent,
      ];
      await sync();
      expect(preferences.histories[_userId], [recent, _now]);
    });

    test('chaque compte applicatif a son propre quota', () async {
      preferences.histories['autre-compte'] = List.filled(
        SyncRateLimit.maxSyncs,
        _now.subtract(const Duration(hours: 1)),
      );
      final result = await sync();
      expect(result.isRight(), isTrue);
    });
  });

  group('GetSyncQuota', () {
    test('quota restant calculé à partir de l’historique', () async {
      preferences.histories[_userId] = [
        _now.subtract(const Duration(hours: 1)),
      ];
      final getSyncQuota = GetSyncQuota(preferences, now: () => _now);
      final result =
          await getSyncQuota(const GetSyncQuotaParams(userId: _userId));
      expect(
        result,
        const Right<Failure, SyncQuota>(
          SyncQuota(remaining: SyncRateLimit.maxSyncs - 1),
        ),
      );
    });
  });
}
