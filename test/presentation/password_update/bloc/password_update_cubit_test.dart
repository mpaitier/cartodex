import 'dart:async';

import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/app_user.dart';
import 'package:cartodex/domain/repositories/auth_repository.dart';
import 'package:cartodex/domain/usecases/change_password.dart';
import 'package:cartodex/domain/usecases/link_password.dart';
import 'package:cartodex/presentation/password_update/bloc/password_update_cubit.dart';
import 'package:cartodex/presentation/password_update/bloc/password_update_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux dépôt d'authentification : seuls l'ajout et le changement de
/// mot de passe sont implémentés. Garde la trace des appels, et
/// [pending] permet de suspendre l'opération pour observer l'état
/// intermédiaire.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({this.failure, this.pending});

  final Failure? failure;
  final Completer<void>? pending;
  final List<String> linkedPasswords = [];
  final List<({String current, String next})> changes = [];

  @override
  Future<Either<Failure, AppUser>> linkPassword({
    required String password,
  }) async {
    linkedPasswords.add(password);
    await pending?.future;
    final failure = this.failure;
    if (failure != null) return Left(failure);
    return const Right(AppUser(uid: 'u1', hasPasswordSignIn: true));
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changes.add((current: currentPassword, next: newPassword));
    await pending?.future;
    final failure = this.failure;
    if (failure != null) return Left(failure);
    return const Right(null);
  }
}

PasswordUpdateCubit _cubit(_FakeAuthRepository repository) =>
    PasswordUpdateCubit(
      linkPassword: LinkPassword(repository),
      changePassword: ChangePassword(repository),
    );

void main() {
  group('PasswordUpdateCubit', () {
    test('démarre sans enregistrement', () {
      final cubit = _cubit(_FakeAuthRepository());
      addTearDown(cubit.close);
      expect(cubit.state, const PasswordUpdateState());
    });

    test('linkPassword ajoute le mot de passe au compte', () async {
      final repository = _FakeAuthRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      await cubit.linkPassword('pikachu25');

      expect(cubit.state.status, PasswordUpdateStatus.success);
      expect(repository.linkedPasswords, ['pikachu25']);
    });

    test('changePassword transmet l’actuel et le nouveau', () async {
      final repository = _FakeAuthRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      await cubit.changePassword(
        currentPassword: 'ancien1',
        newPassword: 'nouveau2',
      );

      expect(cubit.state.status, PasswordUpdateStatus.success);
      expect(repository.changes, [(current: 'ancien1', next: 'nouveau2')]);
    });

    test('passe par l’état d’enregistrement en cours', () async {
      final pending = Completer<void>();
      final cubit = _cubit(_FakeAuthRepository(pending: pending));
      addTearDown(cubit.close);

      final future = cubit.linkPassword('salameche');
      expect(cubit.state.isSaving, isTrue);

      pending.complete();
      await future;
      expect(cubit.state.status, PasswordUpdateStatus.success);
    });

    test('ignore un second envoi tant que le premier est en cours', () async {
      final pending = Completer<void>();
      final repository = _FakeAuthRepository(pending: pending);
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      final first = cubit.linkPassword('carapuce');
      await cubit.linkPassword('carapuce');
      pending.complete();
      await first;

      expect(repository.linkedPasswords, hasLength(1));
    });

    test('expose le message d’un échec', () async {
      final cubit = _cubit(
        _FakeAuthRepository(
          failure: const AuthFailure('Mot de passe actuel incorrect.'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.changePassword(
        currentPassword: 'faux',
        newPassword: 'nouveau2',
      );

      expect(
        cubit.state,
        const PasswordUpdateState(
          status: PasswordUpdateStatus.failure,
          errorMessage: 'Mot de passe actuel incorrect.',
        ),
      );
    });
  });
}
