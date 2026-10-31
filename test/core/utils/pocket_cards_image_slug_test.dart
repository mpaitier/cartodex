import 'package:cartodex/core/utils/pocket_cards_image_slug.dart';
import 'package:cartodex/data/models/card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PocketCardsImageSlug.fromSetCode', () {
    test('un set classique passe simplement en minuscules', () {
      expect(PocketCardsImageSlug.fromSetCode('A1'), 'a1');
      expect(PocketCardsImageSlug.fromSetCode('B2a'), 'b2a');
    });

    test('les promos sont abrégées en p + lettre de série', () {
      expect(PocketCardsImageSlug.fromSetCode('PROMO-A'), 'pa');
      expect(PocketCardsImageSlug.fromSetCode('PROMO-B'), 'pb');
      expect(PocketCardsImageSlug.fromSetCode('PROMO-C'), 'pc');
    });
  });

  group('PocketCardsImageSlug.fromCardName', () {
    test('les accents sont ramenés à la lettre de base', () {
      expect(
        PocketCardsImageSlug.fromCardName('A2b-70', 'Pokémon Center Lady'),
        'pokemon-center-lady',
      );
      expect(PocketCardsImageSlug.fromCardName('X-1', 'Flabébé'), 'flabebe');
    });

    test('une majuscule accentuée garde le découpage camelCase', () {
      expect(
        PocketCardsImageSlug.fromCardName('X-1', 'TealÉclair'),
        'teal-eclair',
      );
    });

    test('les noms sans accent sont inchangés', () {
      expect(
        PocketCardsImageSlug.fromCardName('X-1', "Team Rocket's Moltres ex"),
        'team-rockets-moltres-ex',
      );
      expect(PocketCardsImageSlug.fromCardName('X-1', 'Porygon2'), 'porygon-2');
    });

    test('les corrections manuelles passent avant la conversion', () {
      expect(
        PocketCardsImageSlug.fromCardName('A2a-23', 'Palkia'),
        'origin-forme-palkia',
      );
      expect(
        PocketCardsImageSlug.fromCardName('A2a-60', 'Dialga'),
        'origin-forme-dialga',
      );
    });

    test('une correction ne touche que sa carte', () {
      expect(PocketCardsImageSlug.fromCardName('A2-1', 'Palkia'), 'palkia');
    });
  });

  group('CardModel.fromJson imageUrl', () {
    test('carte au nom accentué', () {
      final card = CardModel.fromJson({
        'set': 'A2b',
        'number': 70,
        'name': 'Pokémon Center Lady',
      });
      expect(
        card.imageUrl,
        'https://pocketcards.net/images/cards/pokemon-center-lady-a2b-070.webp',
      );
    });

    test('carte promo', () {
      final card = CardModel.fromJson({
        'set': 'PROMO-B',
        'number': 8,
        'name': 'Psyduck',
      });
      expect(
        card.imageUrl,
        'https://pocketcards.net/images/cards/psyduck-pb-008.webp',
      );
    });

    test('carte de set classique inchangée', () {
      final card = CardModel.fromJson({
        'set': 'A1',
        'number': 1,
        'name': 'Bulbasaur',
      });
      expect(
        card.imageUrl,
        'https://pocketcards.net/images/cards/bulbasaur-a1-001.webp',
      );
    });
  });
}