import 'package:cartodex/core/utils/percent_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PercentFormatter.twoDecimals', () {
    test('deux décimales avec une virgule par défaut', () {
      expect(PercentFormatter.twoDecimals(12, 35), '34,28');
    });

    test('séparateur décimal au choix (anglais)', () {
      expect(
        PercentFormatter.twoDecimals(12, 35, decimalSeparator: '.'),
        '34.28',
      );
    });

    test('complète les décimales par des zéros', () {
      expect(PercentFormatter.twoDecimals(1, 2), '50,00');
      expect(PercentFormatter.twoDecimals(1, 20), '5,00');
      expect(PercentFormatter.twoDecimals(1, 1000), '0,10');
    });

    test("arrondit vers le bas : jamais 100 s'il manque une carte", () {
      expect(PercentFormatter.twoDecimals(9999, 10000), '99,99');
      expect(PercentFormatter.twoDecimals(19999, 20000), '99,99');
    });

    test('pas d\'écart d\'arrondi des doubles', () {
      expect(PercentFormatter.twoDecimals(29, 100), '29,00');
    });

    test('bornes 0 et 100', () {
      expect(PercentFormatter.twoDecimals(0, 83), '0,00');
      expect(PercentFormatter.twoDecimals(83, 83), '100,00');
    });
  });
}
