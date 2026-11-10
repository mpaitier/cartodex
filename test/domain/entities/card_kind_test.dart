import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/card_kind.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _card(CardCategory category, {List<String> types = const []}) =>
    PokemonCard(
      id: 'A1-1',
      localId: '1',
      name: 'Carte',
      category: category,
      setId: 'A1',
      setName: 'Genetic Apex',
      types: types,
    );

void main() {
  group('CardKind.of', () {
    test("un Pokémon prend son élément", () {
      expect(
        CardKind.of(_card(CardCategory.pokemon, types: ['grass'])),
        CardKind.grass,
      );
      expect(
        CardKind.of(_card(CardCategory.pokemon, types: ['dragon'])),
        CardKind.dragon,
      );
    });

    test('un Pokémon sans élément reconnu est inconnu', () {
      expect(CardKind.of(_card(CardCategory.pokemon)), CardKind.unknown);
      expect(
        CardKind.of(_card(CardCategory.pokemon, types: ['fairy'])),
        CardKind.unknown,
      );
    });

    test('un Dresseur prend son type, même avec des types parasites', () {
      expect(CardKind.of(_card(CardCategory.supporter)), CardKind.supporter);
      expect(CardKind.of(_card(CardCategory.item)), CardKind.item);
      expect(CardKind.of(_card(CardCategory.tool)), CardKind.tool);
      expect(CardKind.of(_card(CardCategory.stadium)), CardKind.stadium);
      expect(
        CardKind.of(_card(CardCategory.fossil, types: ['grass'])),
        CardKind.fossil,
      );
    });

    test('une carte de type inconnu est inconnue', () {
      expect(CardKind.of(_card(CardCategory.unknown)), CardKind.unknown);
    });
  });

  group('CardKind.isElement', () {
    test('vrai pour les éléments seulement', () {
      expect(CardKind.colorless.isElement, isTrue);
      expect(CardKind.grass.isElement, isTrue);
      expect(CardKind.supporter.isElement, isFalse);
      expect(CardKind.unknown.isElement, isFalse);
    });
  });

  group('CardCategory.fromName', () {
    test('reconnaît les types connus', () {
      expect(CardCategory.fromName('stadium'), CardCategory.stadium);
      expect(CardCategory.fromName('fossil'), CardCategory.fossil);
    });

    test('les anciennes valeurs et les inconnues donnent unknown', () {
      expect(CardCategory.fromName('trainer'), CardCategory.unknown);
      expect(CardCategory.fromName('energy'), CardCategory.unknown);
      expect(CardCategory.fromName(null), CardCategory.unknown);
    });
  });
}
