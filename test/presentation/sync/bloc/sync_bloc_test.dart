import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/account.dart';
import 'package:cartodex/domain/entities/cloud_account.dart';
import 'package:cartodex/domain/entities/sync_quota.dart';
import 'package:cartodex/domain/repositories/account_repository.dart';
import 'package:cartodex/domain/repositories/card_repository.dart';
import 'package:cartodex/domain/repositories/cloud_sync_repository.dart';
import 'package:cartodex/domain/repositories/user_preferences_repository.dart';
import 'package:cartodex/domain/services/sync_rate_limit.dart';
import 'package:cartodex/domain/usecases/get_sync_quota.dart';
import 'package:cartodex/domain/usecases/sync_with_cloud.dart';
import 'package:cartodex/presentation/sync/bloc/sync_bloc.dart';
import 'package:cartodex/presentation/sync/bloc/sync_event.dart';
import 'package:cartodex/presentation/sync/bloc/sync_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

const _userId = 'user-1';
final _now = DateTime(2026, 11, 10, 12);

class _FakeAccounts extends Fake implements AccountRepository {
  @override
  Future<Either<Failure, void>> migrateLegacyAccountIds() async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async =>
      const Right([]);
}

class _FakeCards extends Fake implements CardRepository {}

class _FakeCloud extends Fake implements CloudSyncRepository {
  @override
  Future<Either<Failure, List<CloudAccount>>> fetchAccounts(
    String userId,
  ) async =>
      const Right([]);
}

class _FakePreferences extends Fake implements UserPreferencesRepository {
  List<DateTime> history = [];

  @override
  Future<Either<Failure, List<DateTime>>> getSyncHistory(
    String userId,
  ) async =>
      Right(history);

  @override
  Future<Either<Failure, void>> saveSyncHistory(
    String userId,
    List<DateTime> history,
  ) async {
    this.history = history;
    return const Right(null);
  }
}

void main() {
  late _FakePreferences preferences;
  late SyncBloc bloc;

  setUp(() {
    preferences = _FakePreferences();
    bloc = SyncBloc(
      syncWithCloud: SyncWithCloud(
        accountRepository: _FakeAccounts(),
        cardRepository: _FakeCards(),
        cloudSyncRepository: _FakeCloud(),
        userPreferencesRepository: preferences,
        now: () => _now,
      ),
      getSyncQuota: GetSyncQuota(preferences, now: () => _now),
    );
  });

  tearDown(() => bloc.close());

  group('SyncBloc', () {
    test('le quota est calculé à la demande, sans changer le statut',
        () async {
      bloc.add(const SyncQuotaRequested(_userId));
      await expectLater(
        bloc.stream,
        emits(
          const SyncState(
            quota: SyncQuota(remaining: SyncRateLimit.maxSyncs),
          ),
        ),
      );
    });

    test('une synchro réussie met le quota à jour', () async {
      bloc.add(const SyncRequested(_userId));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const SyncState(status: SyncStatus.syncing),
          isA<SyncState>()
              .having((s) => s.status, 'status', SyncStatus.success)
              .having(
                (s) => s.quota,
                'quota',
                const SyncQuota(remaining: SyncRateLimit.maxSyncs - 1),
              ),
        ]),
      );
    });

    test('limite atteinte : statut dédié et heure de la prochaine synchro',
        () async {
      final oldest = _now.subtract(const Duration(hours: 10));
      preferences.history = [
        oldest,
        ...List.filled(
          SyncRateLimit.maxSyncs - 1,
          _now.subtract(const Duration(hours: 1)),
        ),
      ];

      bloc.add(const SyncRequested(_userId));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const SyncState(status: SyncStatus.syncing),
          SyncState(
            status: SyncStatus.quotaExceeded,
            quota: SyncQuota(
              remaining: 0,
              nextAvailableAt: oldest.add(SyncRateLimit.window),
            ),
          ),
        ]),
      );
    });
  });
}
