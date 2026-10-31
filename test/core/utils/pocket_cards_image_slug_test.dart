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

  group('CardModel.fromJson imageUrl', () {
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