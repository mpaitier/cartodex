import 'package:cartodex/domain/entities/card_set.dart';
import 'package:flutter_test/flutter_test.dart';

CardSet _set(String id, String seriesId) => CardSet(
      id: id,
      name: id,
      totalCardCount: 0,
      seriesId: seriesId,
    );

void main() {
  group('CardSet.isPromo', () {
    test('les sets de série principale ne sont pas promo', () {
      expect(_set('A1', 'A').isPromo, isFalse);
      expect(_set('A1a', 'A').isPromo, isFalse);
      expect(_set('A4b', 'A').isPromo, isFalse);
      expect(_set('B2', 'B').isPromo, isFalse);
    });

    test('une nouvelle série est reconnue sans déclaration', () {
      expect(_set('C1', 'C').isPromo, isFalse);
      expect(_set('C1a', 'C').isPromo, isFalse);
    });

    test('les sets PROMO-x sont promo, quelle que soit la série', () {
      expect(_set('PROMO-A', 'A').isPromo, isTrue);
      expect(_set('PROMO-B', 'B').isPromo, isTrue);
      expect(_set('PROMO-C', 'C').isPromo, isTrue);
    });

    test('un code inhabituel dans une série classique part en promo', () {
      expect(_set('SP1', 'A').isPromo, isTrue);
      expect(_set('SP', 'B').isPromo, isTrue);
    });

    test('un code qui ne commence pas par la lettre de sa série part en promo',
        () {
      expect(_set('B1', 'A').isPromo, isTrue);
    });

    test('une clé de série inhabituelle part en promo', () {
      expect(_set('SP1', 'SP').isPromo, isTrue);
      expect(_set('A1', 'SP').isPromo, isTrue);
    });
  });
}