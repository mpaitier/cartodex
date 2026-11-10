import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/card_element.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:cartodex/presentation/set_detail/bloc/ownership_filter.dart';
import 'package:cartodex/presentation/set_detail/bloc/set_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _card(String number, {String? element, String rarity = 'C'}) =>
    PokemonCard(
      id: 'A1-$number',
      localId: number,
      name: 'Carte $number',
      category:
          element == null ? CardCategory.trainer : CardCategory.pokemon,
      setId: 'A1',
      setName: 'Genetic Apex',
      rarity: rarity,
      types: element == null ? const [] : [element],
    );

List<String> _ids(List<PokemonCard> cards) => [for (final c in cards) c.id];

void main() {
  final cards = [
    _card('1', element: 'grass'),
    _card('2', element: 'fire'),
    _card('3', element: 'grass'),
    _card('4'),
  ];

  group('SetDetailState.availableElements', () {
    test("liste les éléments présents, dans l'ordre du jeu", () {
      final state = SetDetailState(cards: cards);
      expect(state.availableElements, [
        CardElement.grass,
        CardElement.fire,
        CardElement.none,
      ]);
    });
  });

  group('SetDetailState.visibleCards et le filtre par type', () {
    test('sans élément coché, toutes les cartes restent visibles', () {
      final state = SetDetailState(cards: cards);
      expect(_ids(state.visibleCards), ['A1-1', 'A1-2', 'A1-3', 'A1-4']);
    });

    test('ne garde que les éléments cochés', () {
      final state = SetDetailState(
        cards: cards,
        selectedElements: const {CardElement.grass},
      );
      expect(_ids(state.visibleCards), ['A1-1', 'A1-3']);
    });

    test('plusieurs éléments cochés se cumulent', () {
      final state = SetDetailState(
        cards: cards,
        selectedElements: const {CardElement.fire, CardElement.none},
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
        selectedElements: const {CardElement.grass, CardElement.fire},
        ownershipFilter: OwnershipFilter.notOwned,
      );
      expect(state.activeFilterCount, 3);
    });
  });
}
