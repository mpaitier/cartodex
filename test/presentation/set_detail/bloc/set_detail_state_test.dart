import 'package:cartodex/domain/entities/account.dart';
import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/card_kind.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:cartodex/presentation/set_detail/bloc/ownership_filter.dart';
import 'package:cartodex/presentation/set_detail/bloc/set_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _pokemon(String number, String element) => PokemonCard(
      id: 'A1-$number',
      localId: number,
      name: 'Carte $number',
      category: CardCategory.pokemon,
      setId: 'A1',
      setName: 'Genetic Apex',
      rarity: 'C',
      types: [element],
    );

PokemonCard _trainer(String number, CardCategory category) => PokemonCard(
      id: 'A1-$number',
      localId: number,
      name: 'Carte $number',
      category: category,
      setId: 'A1',
      setName: 'Genetic Apex',
      rarity: 'C',
    );

List<String> _ids(List<PokemonCard> cards) => [for (final c in cards) c.id];

void main() {
  final cards = [
    _trainer('1', CardCategory.item),
    _pokemon('2', 'fire'),
    _pokemon('3', 'grass'),
    _trainer('4', CardCategory.supporter),
    _pokemon('5', 'grass'),
  ];

  group('SetDetailState.availableKinds', () {
    test('liste les éléments puis les types de Dresseur présents', () {
      final state = SetDetailState(cards: cards);
      expect(state.availableKinds, [
        CardKind.grass,
        CardKind.fire,
        CardKind.supporter,
        CardKind.item,
      ]);
    });
  });

  group('SetDetailState.visibleCards et le filtre par type', () {
    test('sans type coché, toutes les cartes restent visibles', () {
      final state = SetDetailState(cards: cards);
      expect(_ids(state.visibleCards), ['A1-1', 'A1-2', 'A1-3', 'A1-4', 'A1-5']);
    });

    test('ne garde que les éléments cochés', () {
      final state = SetDetailState(
        cards: cards,
        selectedKinds: const {CardKind.grass},
      );
      expect(_ids(state.visibleCards), ['A1-3', 'A1-5']);
    });

    test('mélange éléments et types de Dresseur', () {
      final state = SetDetailState(
        cards: cards,
        selectedKinds: const {CardKind.fire, CardKind.supporter},
      );
      expect(_ids(state.visibleCards), ['A1-2', 'A1-4']);
    });
  });

  group('SetDetailState.activeFilterCount', () {
    test('vaut 0 sans aucun filtre', () {
      expect(SetDetailState(cards: cards).activeFilterCount, 0);
    });

    test('compte un par filtre actif, quel que soit le nombre de puces', () {
      final state = SetDetailState(
        cards: cards,
        selectedPack: 'Mewtwo',
        selectedKinds: const {CardKind.grass, CardKind.item},
        ownershipFilter: OwnershipFilter.notOwned,
      );
      expect(state.activeFilterCount, 3);
    });
  });

  group('SetDetailState : compteurs de progression filtrés', () {
    final progressCards = [
      _pokemon('1', 'grass'),
      _pokemon('2', 'grass'),
      _pokemon('3', 'fire'),
      _trainer('4', CardCategory.item),
    ];
    // Toutes les cartes de test sont de rareté "C" : collection de base.
    const ownedByPrimary = {'1', '3'};

    SetDetailState stateWith({
      Set<CardKind> kinds = const {},
      OwnershipFilter ownership = OwnershipFilter.all,
    }) {
      return SetDetailState(
        cards: progressCards,
        accounts: [
          Account(
            id: 'main',
            name: 'Principal',
            gameAccountId: '0000',
            isPrimary: true,
            createdAt: DateTime(2026),
          ),
        ],
        ownershipByAccountId: {
          'main': {for (final n in ownedByPrimary) 'A1-$n'},
        },
        selectedKinds: kinds,
        ownershipFilter: ownership,
      );
    }

    test('sans filtre, portent sur tout le set', () {
      final state = stateWith();
      expect(state.baseTotal, 4);
      expect(state.baseOwned, 2);
      expect(state.hasContentFilters, isFalse);
    });

    test('suivent le filtre par type', () {
      final state = stateWith(kinds: const {CardKind.grass});
      expect(state.baseTotal, 2);
      expect(state.baseOwned, 1);
      expect(state.hasContentFilters, isTrue);
    });

    test('ignorent le filtre de possession', () {
      final state = stateWith(ownership: OwnershipFilter.notOwned);
      expect(state.baseTotal, 4);
      expect(state.baseOwned, 2);
      expect(state.hasContentFilters, isFalse);
    });
  });

  group('SetDetailState : cartes uniques', () {
    // A1 : le principal a 1, alice a 2 et 3, bob a 3 et 4.
    // Seule la carte 2 est unique à alice, seule la 4 l'est à bob.
    final uniqueCards = [
      _pokemon('1', 'grass'),
      _pokemon('2', 'grass'),
      _pokemon('3', 'fire'),
      _pokemon('4', 'fire'),
      _pokemon('5', 'fire'),
    ];

    Account account(String id, {bool isPrimary = false}) => Account(
          id: id,
          name: id,
          gameAccountId: '0000',
          isPrimary: isPrimary,
          createdAt: DateTime(2026),
        );

    SetDetailState stateWith({
      OwnershipFilter ownership = OwnershipFilter.secondary,
      String? secondaryAccountId,
      String? ownerAccountId,
      bool uniqueOnly = false,
      Set<CardKind> kinds = const {},
    }) {
      return SetDetailState(
        cards: uniqueCards,
        accounts: [
          account('main', isPrimary: true),
          account('alice'),
          account('bob'),
        ],
        ownershipByAccountId: const {
          'main': {'A1-1'},
          'alice': {'A1-2', 'A1-3'},
          'bob': {'A1-3', 'A1-4'},
        },
        ownershipFilter: ownership,
        secondaryFilterAccountId: secondaryAccountId,
        ownerFilterAccountId: ownerAccountId,
        uniqueOnly: uniqueOnly,
        selectedKinds: kinds,
      );
    }

    test("n'est pas proposé sans compte secondaire précis", () {
      final state = stateWith(uniqueOnly: true);
      expect(state.isUniqueFilterAvailable, isFalse);
      expect(state.effectiveUniqueOnly, isFalse);
      expect(_ids(state.visibleCards), ['A1-2', 'A1-3', 'A1-4']);
    });

    test('compte les cartes uniques du compte choisi', () {
      expect(stateWith(secondaryAccountId: 'alice').uniqueCardCount, 1);
      expect(stateWith(secondaryAccountId: 'bob').uniqueCardCount, 1);
    });

    test('ne garde que les cartes que ce compte est seul à avoir', () {
      final alice = stateWith(secondaryAccountId: 'alice', uniqueOnly: true);
      expect(_ids(alice.visibleCards), ['A1-2']);
      final bob = stateWith(secondaryAccountId: 'bob', uniqueOnly: true);
      expect(_ids(bob.visibleCards), ['A1-4']);
    });

    test("s'applique aussi à un écran restreint à un compte", () {
      final state = stateWith(
        ownership: OwnershipFilter.all,
        ownerAccountId: 'bob',
        uniqueOnly: true,
      );
      expect(state.isUniqueFilterAvailable, isTrue);
      expect(_ids(state.visibleCards), ['A1-4']);
      expect(state.activeFilterCount, 1);
    });

    test('le compteur suit le filtre par type', () {
      final state = stateWith(
        secondaryAccountId: 'alice',
        kinds: const {CardKind.fire},
      );
      expect(state.uniqueCardCount, 0);
    });

    test('compte avec la possession dans les filtres actifs', () {
      final state = stateWith(secondaryAccountId: 'alice', uniqueOnly: true);
      expect(state.activeFilterCount, 1);
    });
  });
}
