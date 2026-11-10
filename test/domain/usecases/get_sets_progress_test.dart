import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/set_progress.dart';
import 'package:cartodex/domain/usecase.dart';
import 'package:cartodex/domain/usecases/get_sets_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

const _genetic =
    CardSet(id: 'A1', name: 'Genetic Apex', totalCardCount: 4, seriesId: 'A');

/// A1 : deux cartes losange (C, U) et deux alternatives (AR, SR).
final _cards = {
  'A1': [
    testCard('A1', 1, 'C'),
    testCard('A1', 2, 'U'),
    testCard('A1', 3, 'AR'),
    testCard('A1', 4, 'SR'),
  ],
};

void main() {
  group('GetSetsProgress', () {
    test('sans compte principal, aucune progression', () async {
      final useCase = GetSetsProgress(
        cardRepository: FakeCardRepository(
          sets: const [_genetic],
          cardsBySetId: _cards,
        ),
        accountRepository:
            FakeAccountRepository(accounts: [testAccount('second')]),
      );

      final result = await useCase(const NoParams());

      expect(result.getOrElse(() => throw StateError('échec')), isEmpty);
    });

    test(
        'principal, puis secondaires sans double-comptage, '
        'séparés losange / alternatif', () async {
      final useCase = GetSetsProgress(
        cardRepository: FakeCardRepository(
          sets: const [_genetic],
          cardsBySetId: _cards,
          ownedByAccountId: {
            'main': {'A1-1', 'A1-3'},
            // A1-1 est aussi au principal : il ne compte qu'une fois.
            'second': {'A1-1', 'A1-2'},
            'third': {'A1-4'},
          },
        ),
        accountRepository: FakeAccountRepository(
          accounts: [
            testAccount('main', isPrimary: true),
            testAccount('second'),
            testAccount('third'),
          ],
        ),
      );

      final result = await useCase(const NoParams());
      final progress = result.getOrElse(() => throw StateError('échec'));

      expect(
        progress['A1'],
        const SetProgress(
          setId: 'A1',
          base: RarityGroupProgress(
            primaryOwned: 1,
            allAccountsOwned: 2,
            total: 2,
          ),
          alternative: RarityGroupProgress(
            primaryOwned: 1,
            allAccountsOwned: 2,
            total: 2,
          ),
        ),
      );
    });

    test('un échec de lecture des comptes est remonté', () async {
      const failure = CacheFailure('comptes illisibles');
      final useCase = GetSetsProgress(
        cardRepository: FakeCardRepository(sets: const [_genetic]),
        accountRepository: FakeAccountRepository(failure: failure),
      );

      expect(
        (await useCase(const NoParams())).fold((f) => f, (_) => null),
        failure,
      );
    });
  });
}
