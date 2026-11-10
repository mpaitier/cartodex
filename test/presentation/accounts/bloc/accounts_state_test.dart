import 'package:cartodex/domain/entities/account.dart';
import 'package:cartodex/domain/entities/account_extras.dart';
import 'package:cartodex/domain/entities/accounts_sort_option.dart';
import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/presentation/accounts/bloc/accounts_state.dart';
import 'package:flutter_test/flutter_test.dart';

Account _account(String id, {bool primary = false, int order = 0}) => Account(
      id: id,
      name: id,
      gameAccountId: '0000',
      isPrimary: primary,
      createdAt: DateTime(2026, 1, 1 + order),
    );

CardSet _set(String id, String name) =>
    CardSet(id: id, name: name, totalCardCount: 0, seriesId: 'A');

SetExtras _extras(CardSet set, {int base = 0, int alternative = 0}) =>
    SetExtras(
      set: set,
      counts: ExtraCounts(base: base, alternative: alternative),
    );

List<String> _ids(List<Account> accounts) => [for (final a in accounts) a.id];

void main() {
  final eevee = _set('A3b', 'Eevee Grove');
  final apex = _set('A1', 'Genetic Apex');

  final accounts = [
    _account('main', primary: true),
    _account('bob', order: 1),
    _account('alice', order: 2),
    _account('carl', order: 3),
  ];

  final extras = {
    'bob': AccountExtras(
      accountId: 'bob',
      bySet: [_extras(apex, base: 9), _extras(eevee, base: 1)],
    ),
    'alice': AccountExtras(
      accountId: 'alice',
      bySet: [_extras(eevee, base: 4, alternative: 1)],
    ),
    'carl': AccountExtras(accountId: 'carl', bySet: [_extras(apex, base: 2)]),
  };

  AccountsState stateWith({
    Set<String> setFilterIds = const {},
    AccountsSortOption sort = AccountsSortOption.creationOrder,
  }) {
    return AccountsState(
      accounts: accounts,
      extrasByAccountId: extras,
      setFilterIds: setFilterIds,
      sortOption: sort,
    );
  }

  group('AccountsState.availableFilterSets', () {
    test('liste les extensions avec des cartes en plus, par nom', () {
      expect(
        [for (final s in stateWith().availableFilterSets) s.name],
        ['Eevee Grove', 'Genetic Apex'],
      );
    });
  });

  group('AccountsState.sortedAccounts et le filtre par extension', () {
    test('sans filtre, principal en tête puis tous les secondaires', () {
      expect(_ids(stateWith().sortedAccounts), ['main', 'bob', 'alice', 'carl']);
    });

    test("ne garde que les secondaires qui ont l'extension, sans le principal",
        () {
      expect(
        _ids(stateWith(setFilterIds: {'A3b'}).sortedAccounts),
        ['bob', 'alice'],
      );
    });

    test('plusieurs extensions cochées élargissent le filtre', () {
      expect(
        _ids(stateWith(setFilterIds: {'A3b', 'A1'}).sortedAccounts),
        ['bob', 'alice', 'carl'],
      );
    });

    test('trie sur les cartes en plus cumulées des extensions filtrées', () {
      final state = stateWith(
        setFilterIds: {'A3b', 'A1'},
        sort: AccountsSortOption.extraCards,
      );
      // bob : 9 + 1, alice : 4 + 1, carl : 2.
      expect(_ids(state.sortedAccounts), ['bob', 'alice', 'carl']);
    });

    test("une extension qui n'est plus proposée n'est plus appliquée", () {
      final state = stateWith(setFilterIds: {'B1'});
      expect(state.isSetFiltered, isFalse);
      expect(_ids(state.sortedAccounts), ['main', 'bob', 'alice', 'carl']);
    });
  });

  group('AccountsState.filteredCountsFor', () {
    test('cumule les cartes en plus des extensions filtrées', () {
      final state = stateWith(setFilterIds: {'A3b', 'A1'});
      expect(state.filteredCountsFor(accounts[1])?.base, 10);
      expect(state.filteredCountsFor(accounts[2])?.alternative, 1);
    });

    test("vaut null pour un compte qui n'a rien dans ces extensions", () {
      final state = stateWith(setFilterIds: {'A3b'});
      expect(state.filteredCountsFor(accounts[3]), isNull);
    });

    test('vaut null sans filtre', () {
      expect(stateWith().filteredCountsFor(accounts[1]), isNull);
    });
  });

  group('AccountsState.singleFilteredSetExtrasFor', () {
    test("donne l'extension quand une seule est cochée", () {
      final state = stateWith(setFilterIds: {'A3b'});
      expect(state.singleFilteredSetExtrasFor(accounts[2])?.counts.base, 4);
    });

    test('vaut null dès que plusieurs extensions sont cochées', () {
      final state = stateWith(setFilterIds: {'A3b', 'A1'});
      expect(state.singleFilteredSetExtrasFor(accounts[1]), isNull);
    });
  });

  group('AccountsState.previewSetsFor', () {
    test("sans filtre, toutes les extensions du compte, dans l'ordre", () {
      expect(
        [for (final e in stateWith().previewSetsFor(accounts[1])) e.set.id],
        ['A1', 'A3b'],
      );
    });

    test('avec un filtre, seulement les extensions filtrées', () {
      final state = stateWith(setFilterIds: {'A3b'});
      expect(
        [for (final e in state.previewSetsFor(accounts[1])) e.set.id],
        ['A3b'],
      );
    });
  });
}
