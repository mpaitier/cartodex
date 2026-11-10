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
    String? setFilterId,
    AccountsSortOption sort = AccountsSortOption.creationOrder,
  }) {
    return AccountsState(
      accounts: accounts,
      extrasByAccountId: extras,
      setFilterId: setFilterId,
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
        _ids(stateWith(setFilterId: 'A3b').sortedAccounts),
        ['bob', 'alice'],
      );
    });

    test("trie sur les cartes en plus de l'extension filtrée", () {
      final state = stateWith(
        setFilterId: 'A3b',
        sort: AccountsSortOption.extraCards,
      );
      expect(_ids(state.sortedAccounts), ['alice', 'bob']);
    });

    test("une extension qui n'est plus proposée n'est plus appliquée", () {
      final state = stateWith(setFilterId: 'B1');
      expect(state.activeFilterSet, isNull);
      expect(_ids(state.sortedAccounts), ['main', 'bob', 'alice', 'carl']);
    });
  });

  group('AccountsState.filteredSetExtrasFor', () {
    test("donne les cartes en plus de l'extension filtrée", () {
      final state = stateWith(setFilterId: 'A3b');
      expect(state.filteredSetExtrasFor(accounts[2])?.counts.base, 4);
      expect(state.filteredSetExtrasFor(accounts[3]), isNull);
    });

    test('vaut null sans filtre', () {
      expect(stateWith().filteredSetExtrasFor(accounts[1]), isNull);
    });
  });

  group('AccountsState.copyWith', () {
    test('retire le filtre avec null, le garde sans paramètre', () {
      final filtered = stateWith(setFilterId: 'A3b');
      expect(filtered.copyWith().setFilterId, 'A3b');
      expect(filtered.copyWith(setFilterId: null).setFilterId, isNull);
    });
  });
}
