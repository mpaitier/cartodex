import 'package:cartodex/core/utils/pack_display_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PackDisplayName.of', () {
    test("retire le nom de l'extension répété en tête", () {
      expect(
        PackDisplayName.of('Dual Fusion', 'Dual Fusion Mega Mewtwo X'),
        'Mega Mewtwo X',
      );
      expect(
        PackDisplayName.of('Dual Fusion', 'Dual Fusion Pikachu'),
        'Pikachu',
      );
    });

    test('laisse les noms sans préfixe tels quels', () {
      expect(PackDisplayName.of('Genetic Apex', 'Mewtwo'), 'Mewtwo');
      expect(
        PackDisplayName.of('Mega Rising', 'Mega Blaziken'),
        'Mega Blaziken',
      );
    });

    test('garde le nom complet si rien ne resterait', () {
      expect(
        PackDisplayName.of('Ruler of the Skies', 'Ruler of the Skies'),
        'Ruler of the Skies',
      );
    });
  });
}
