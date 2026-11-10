import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/card_element.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _card({List<String> types = const []}) => PokemonCard(
      id: 'A1-1',
      localId: '1',
      name: 'Bulbasaur',
      category: CardCategory.pokemon,
      setId: 'A1',
      setName: 'Genetic Apex',
      types: types,
    );

void main() {
  group('CardElement.of', () {
    test("lit l'élément depuis les types de la carte", () {
      expect(CardElement.of(_card(types: ['grass'])), CardElement.grass);
      expect(CardElement.of(_card(types: ['dragon'])), CardElement.dragon);
    });

    test('une carte sans type est un Dresseur', () {
      expect(CardElement.of(_card()), CardElement.none);
    });

    test('un code inconnu retombe sur none', () {
      expect(CardElement.of(_card(types: ['fairy'])), CardElement.none);
    });

    test('garde le premier code reconnu', () {
      expect(
        CardElement.of(_card(types: ['fairy', 'water', 'fire'])),
        CardElement.water,
      );
    });
  });
}
