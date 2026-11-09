import 'package:cartodex/data/models/set_pull_rates_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetPullRatesModel.fromJson', () {
    test('convertit les pourcentages en fractions et garde chaque variante',
        () {
      final model = SetPullRatesModel.fromJson('A1', {
        'Regular Pack': {
          'appearance_rate': 99.95,
          'cards': 2,
          'slots': {
            '1': {'C': 100.0},
            '2': {'U': 90, 'R': 10.0},
          },
        },
        'Rare Pack': {
          'appearance_rate': 0.05,
          'cards': 1,
          'slots': {
            '1': {'SR': 100.0},
          },
        },
      });

      expect(model.setId, 'A1');
      expect(model.variants.map((v) => v.name), ['Regular Pack', 'Rare Pack']);
      final regular = model.variants.first;
      expect(regular.appearanceRate, closeTo(0.9995, 1e-9));
      expect(regular.slots, hasLength(2));
      expect(regular.slots.first.rateByRarity, {'C': 1.0});
      expect(regular.slots.last.rateByRarity['U'], closeTo(0.9, 1e-9));
      expect(regular.slots.last.rateByRarity['R'], closeTo(0.1, 1e-9));
    });

    test('remet les emplacements dans l’ordre, qu’ils partent de 0 ou de 1',
        () {
      final model = SetPullRatesModel.fromJson('B2b', {
        'Themed Rare Pack': {
          'appearance_rate': 0.005,
          'slots': {
            '10': {'SR': 100.0},
            '0': {'SSR': 100.0},
            '2': {'IM': 100.0},
          },
        },
      });

      final slots = model.variants.single.slots;
      expect(
        slots.map((slot) => slot.rateByRarity.keys.single),
        ['SSR', 'IM', 'SR'],
      );
    });

    test('ignore une variante sans emplacement exploitable', () {
      final model = SetPullRatesModel.fromJson('A1', {
        'Empty Pack': {'appearance_rate': 1, 'slots': <String, dynamic>{}},
        'Broken Pack': 'n/a',
      });

      expect(model.variants, isEmpty);
    });
  });
}
