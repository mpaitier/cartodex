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
}
