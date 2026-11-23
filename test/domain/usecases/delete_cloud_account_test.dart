import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/repositories/account_repository.dart';
import 'package:cartodex/domain/repositories/auth_repository.dart';
import 'package:cartodex/domain/repositories/cloud_sync_repository.dart';
import 'package:cartodex/domain/repositories/user_preferences_repository.dart';
import 'package:cartodex/domain/usecases/delete_cloud_account.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Journal commun aux faux dépôts : l'ordre des appels compte autant
/// que les appels eux-mêmes (rien d'irréversible avant une étape
/// réussie).
typedef _Log = List<String>;

Either<Failure, void> _result(Failure? failure) =>
    failure == null ? const Right(null) : Left(failure);

class _FakeAuth extends Fake implements AuthRepository {
  _FakeAuth(this.log, {this.reauthFailure, this.deleteFailure});

  final _Log log;
  final Failure? reauthFailure;
  final Failure? deleteFailure;

  @override
  Future<Either<Failure, void>> reauthenticate({String? password}) async {
    log.add('reauth:${password ?? 'google'}');
    return _result(reauthFailure);
  }

  @override
  Future<Either<Failure, void>> deleteCurrentUser() async {
    log.add('deleteUser');
    return _result(deleteFailure);
  }
}

class _FakeCloud extends Fake implements CloudSyncRepository {
  _FakeCloud(this.log, {this.failure});

  final _Log log;
  final Failure? failure;

  @override
  Future<Either<Failure, void>> deleteAllAccounts(String userId) async {
    log.add('deleteCloud:$userId');
    return _result(failure);
  }
}

class _FakePreferences extends Fake implements UserPreferencesRepository {
  _FakePreferences(this.log, {this.failure});

  final _Log log;
  final Failure? failure;

  @override
  Future<Either<Failure, void>> saveSyncHistory(
    String userId,
    List<DateTime> history,
  ) async {
    log.add('clearHistory:$userId:${history.length}');
    return _result(failure);
  }
}

class _FakeAccounts extends Fake implements AccountRepository {
  _FakeAccounts(this.log, {this.failure});

  final _Log log;
  final Failure? failure;

  @override
  Future<Either<Failure, void>> deleteAllLocalData() async {
    log.add('deleteLocal');
    return _result(failure);
  }
}

DeleteCloudAccount _useCase(
  _Log log, {
  Failure? reauthFailure,
  Failure? cloudFailure,
  Failure? deleteUserFailure,
  Failure? historyFailure,
  Failure? localFailure,
}) =>
    DeleteCloudAccount(
      authRepository: _FakeAuth(
        log,
        reauthFailure: reauthFailure,
        deleteFailure: deleteUserFailure,
      ),
      cloudSyncRepository: _FakeCloud(log, failure: cloudFailure),
      userPreferencesRepository: _FakePreferences(log, failure: historyFailure),
      accountRepository: _FakeAccounts(log, failure: localFailure),
    );

void main() {
  group('DeleteCloudAccount', () {
    test('confirme, efface le cloud, puis le compte et l’historique',
        () async {
      final log = <String>[];

      final result = await _useCase(log)(
        const DeleteCloudAccountParams(userId: 'u1', password: 'secret'),
      );

      expect(result, const Right<Failure, void>(null));
      expect(log, [
        'reauth:secret',
        'deleteCloud:u1',
        'deleteUser',
        'clearHistory:u1:0',
      ]);
    });

    test('confirme avec Google quand aucun mot de passe n’est donné',
        () async {
      final log = <String>[];

      await _useCase(log)(const DeleteCloudAccountParams(userId: 'u1'));

      expect(log.first, 'reauth:google');
    });

    test('efface aussi le téléphone sur demande, en dernier', () async {
      final log = <String>[];

      final result = await _useCase(log)(
        const DeleteCloudAccountParams(userId: 'u1', deleteLocalData: true),
      );

      expect(result.isRight(), isTrue);
      expect(log.last, 'deleteLocal');
    });

    test('ne touche à rien si la confirmation échoue', () async {
      final log = <String>[];
      const failure = AuthFailure('Mot de passe incorrect.');

      final result = await _useCase(log, reauthFailure: failure)(
        const DeleteCloudAccountParams(
          userId: 'u1',
          password: 'faux',
          deleteLocalData: true,
        ),
      );

      expect(result, const Left<Failure, void>(failure));
      expect(log, ['reauth:faux']);
    });

    test('garde le compte si le cloud n’a pas pu être effacé', () async {
      final log = <String>[];
      const failure = ServerFailure('hors ligne');

      final result = await _useCase(log, cloudFailure: failure)(
        const DeleteCloudAccountParams(userId: 'u1', deleteLocalData: true),
      );

      expect(result, const Left<Failure, void>(failure));
      expect(log, ['reauth:google', 'deleteCloud:u1']);
    });

    test('n’efface pas le téléphone si le compte n’a pas été supprimé',
        () async {
      final log = <String>[];
      const failure = AuthFailure('Reconnecte-toi.');

      final result = await _useCase(log, deleteUserFailure: failure)(
        const DeleteCloudAccountParams(userId: 'u1', deleteLocalData: true),
      );

      expect(result, const Left<Failure, void>(failure));
      expect(log, isNot(contains('deleteLocal')));
    });

    test('ignore un échec sur l’historique de synchronisation', () async {
      final log = <String>[];

      final result = await _useCase(
        log,
        historyFailure: const CacheFailure('préférences illisibles'),
      )(const DeleteCloudAccountParams(userId: 'u1'));

      expect(result.isRight(), isTrue);
    });

    test('signale un téléphone non effacé après la suppression du compte',
        () async {
      final log = <String>[];

      final result = await _useCase(
        log,
        localFailure: const CacheFailure('base verrouillée'),
      )(const DeleteCloudAccountParams(userId: 'u1', deleteLocalData: true));

      expect(result.isLeft(), isTrue);
      expect(log, contains('deleteUser'));
    });
  });
}
