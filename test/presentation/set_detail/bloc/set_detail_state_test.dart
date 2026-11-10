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
}
