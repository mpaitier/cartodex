import 'package:cartodex/domain/entities/card_set.dart';
import 'package:cartodex/domain/entities/set_category.dart';
import 'package:flutter_test/flutter_test.dart';

CardSet _set(String id, String seriesId, {String? name}) => CardSet(
      id: id,
      name: name ?? id,
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

  group('CardSet.category', () {
    test('les boosters Deluxe sortent de leur série', () {
      final ex = _set('A4b', 'A', name: 'Deluxe Pack: ex');
      final mega = _set('B4b', 'B', name: 'Deluxe Pack: Mega');
      expect(ex.category, SetCategory.deluxe);
      expect(mega.category, SetCategory.deluxe);
      expect(ex.isPromo, isFalse);
    });

    test('Deluxe est reconnu même avec un code inhabituel', () {
      expect(
        _set('DX1', 'SP', name: 'Deluxe Pack: Future').category,
        SetCategory.deluxe,
      );
    });

    test('la casse du nom ne compte pas', () {
      expect(_set('C4b', 'C', name: 'DELUXE PACK: X').isDeluxe, isTrue);
    });

    test('un nom sans "Deluxe Pack" ne suffit pas', () {
      expect(_set('A4', 'A', name: 'Deluxe').category, SetCategory.main);
      expect(_set('A1', 'A', name: 'Genetic Apex').category, SetCategory.main);
    });

    test('les promos restent promo', () {
      expect(_set('PROMO-A', 'A').category, SetCategory.promo);
    });
  });
}