import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _card({String? nameFr}) => PokemonCard(
      id: 'PROMO-B-3',
      localId: '3',
      name: 'Froakie',
      nameFr: nameFr,
      category: CardCategory.pokemon,
      setId: 'PROMO-B',
      setName: 'Promo-B',
    );

void main() {
  group('PokemonCard.localizedName', () {
    test('nom français quand l’app est en français', () {
      expect(_card(nameFr: 'Grenousse').localizedName('fr'), 'Grenousse');
    });

    test('nom anglais quand l’app est en anglais', () {
      expect(_card(nameFr: 'Grenousse').localizedName('en'), 'Froakie');
    });

    test('repli sur le nom anglais sans traduction', () {
      expect(_card().localizedName('fr'), 'Froakie');
      expect(_card(nameFr: '').localizedName('fr'), 'Froakie');
    });
  });
}
