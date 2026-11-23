import 'dart:async';

import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/repositories/auth_repository.dart';
import 'package:cartodex/domain/usecases/send_password_reset_email.dart';
import 'package:cartodex/presentation/password_reset/bloc/password_reset_cubit.dart';
import 'package:cartodex/presentation/password_reset/bloc/password_reset_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux dépôt d'authentification : seul l'envoi du lien est
/// implémenté. Garde la trace des appels, et [pending] permet de
/// suspendre l'envoi pour observer l'état intermédiaire.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({this.failure, this.pending});

  final Failure? failure;
  final Completer<void>? pending;
  final List<({String email, String? languageCode})> calls = [];

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  }) async {
    calls.add((email: email, languageCode: languageCode));
    await pending?.future;
    final failure = this.failure;
    if (failure != null) return Left(failure);
    return const Right(null);
  }
}

PasswordResetCubit _cubit(_FakeAuthRepository repository) =>
    PasswordResetCubit(
      sendPasswordResetEmail: SendPasswordResetEmail(repository),
    );

void main() {
  group('PasswordResetCubit', () {
    test('démarre sans envoi', () {
      final cubit = _cubit(_FakeAuthRepository());
      addTearDown(cubit.close);
      expect(cubit.state, const PasswordResetState());
    });

    test('envoie le lien à l’email nettoyé, dans la langue donnée', () async {
      final repository = _FakeAuthRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      await cubit.submit(
        email: '  sacha@bourg-palette.fr ',
        languageCode: 'fr',
      );

      expect(
        cubit.state,
        const PasswordResetState(
          status: PasswordResetStatus.sent,
          email: 'sacha@bourg-palette.fr',
        ),
      );
      expect(repository.calls, [
        (email: 'sacha@bourg-palette.fr', languageCode: 'fr'),
      ]);
    });

    test('passe par l’état d’envoi en cours', () async {
      final pending = Completer<void>();
      final cubit = _cubit(_FakeAuthRepository(pending: pending));
      addTearDown(cubit.close);

      final future = cubit.submit(email: 'ondine@azuria.fr');
      expect(cubit.state.status, PasswordResetStatus.sending);
      expect(cubit.state.isSending, isTrue);

      pending.complete();
      await future;
      expect(cubit.state.status, PasswordResetStatus.sent);
    });

    test('ignore un second envoi tant que le premier est en cours', () async {
      final pending = Completer<void>();
      final repository = _FakeAuthRepository(pending: pending);
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      final first = cubit.submit(email: 'pierre@argenta.fr');
      await cubit.submit(email: 'pierre@argenta.fr');
      pending.complete();
      await first;

      expect(repository.calls, hasLength(1));
    });

    test('expose le message d’un échec', () async {
      final cubit = _cubit(
        _FakeAuthRepository(
          failure: const AuthFailure('Adresse email invalide.'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.submit(email: 'pas-un-email@');

      expect(
        cubit.state,
        const PasswordResetState(
          status: PasswordResetStatus.failure,
          email: 'pas-un-email@',
          errorMessage: 'Adresse email invalide.',
        ),
      );
    });

    test('permet de réessayer après un échec', () async {
      final cubit = _cubit(
        _FakeAuthRepository(
          failure: const AuthFailure('Aucune connexion réseau.'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.submit(email: 'red@kanto.fr');
      await cubit.submit(email: 'red@kanto.fr');

      expect(cubit.state.status, PasswordResetStatus.failure);
    });
  });
}
