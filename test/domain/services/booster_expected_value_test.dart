import 'package:cartodex/domain/entities/card_category.dart';
import 'package:cartodex/domain/entities/pack_variant_pull_rates.dart';
import 'package:cartodex/domain/entities/pokemon_card.dart';
import 'package:cartodex/domain/entities/set_pull_rates.dart';
import 'package:cartodex/domain/entities/slot_pull_rates.dart';
import 'package:cartodex/domain/services/booster_expected_value.dart';
import 'package:flutter_test/flutter_test.dart';

PokemonCard _card(String id, String rarity) => PokemonCard(
      id: id,
      localId: id,
      name: id,
      category: CardCategory.pokemon,
      setId: 'A1',
      setName: 'A1',
      rarity: rarity,
      packs: const ['Mewtwo'],
    );

/// Un booster à deux emplacements : le premier toujours commun, le
/// second commun ou rare à parts égales.
SetPullRates _rates({double rareVariantRate = 0}) => SetPullRates(
      setId: 'A1',
      variants: [
        PackVariantPullRates(
          name: 'Regular Pack',
          appearanceRate: 1 - rareVariantRate,
          slots: const [
            SlotPullRates({'C': 1}),
            SlotPullRates({'C': 0.5, 'SR': 0.5}),
          ],
        ),
        if (rareVariantRate > 0)
          PackVariantPullRates(
            name: 'Rare Pack',
            appearanceRate: rareVariantRate,
            slots: const [
              SlotPullRates({'SR': 1}),
              SlotPullRates({'SR': 1}),
            ],
          ),
      ],
    );

void main() {
  const calculator = BoosterExpectedValue();

  group('BoosterExpectedValue.compute', () {
    test('rien ne manque : espérance nulle', () {
      final cards = [_card('c1', 'C'), _card('s1', 'SR')];
      expect(
        calculator.compute(
          pullRates: _rates(),
          boosterCards: cards,
          isWanted: (_) => false,
        ),
        0,
      );
    });

    test('tout manque : une carte par emplacement', () {
      final cards = [_card('c1', 'C'), _card('c2', 'C'), _card('s1', 'SR')];
      expect(
        calculator.compute(
          pullRates: _rates(),
          boosterCards: cards,
          isWanted: (_) => true,
        ),
        closeTo(2, 1e-9),
      );
    });

    test('pondère par la part des cartes manquantes dans chaque rareté', () {
      // 1 commune manquante sur 2 : 1 × 1/2 + 0,5 × 1/2 = 0,75.
      // La rare est possédée : rien de plus.
      final cards = [_card('c1', 'C'), _card('c2', 'C'), _card('s1', 'SR')];
      expect(
        calculator.compute(
          pullRates: _rates(),
          boosterCards: cards,
          isWanted: (card) => card.id == 'c1',
        ),
        closeTo(0.75, 1e-9),
      );
    });

    test('pondère par la probabilité d’apparition de chaque variante', () {
      // Seule la rare manque. Booster normal (90 %) : 0,5. Booster
      // rare (10 %) : 2. Soit 0,9 × 0,5 + 0,1 × 2 = 0,65.
      final cards = [_card('c1', 'C'), _card('s1', 'SR')];
      expect(
        calculator.compute(
          pullRates: _rates(rareVariantRate: 0.1),
          boosterCards: cards,
          isWanted: (card) => card.id == 's1',
        ),
        closeTo(0.65, 1e-9),
      );
    });

    test('tire les SAR dans le même lot que les SR', () {
      // Une SR possédée, une SAR manquante : 0,5 × 1/2 = 0,25.
      final cards = [_card('s1', 'SR'), _card('sa1', 'SAR')];
      expect(
        calculator.compute(
          pullRates: _rates(),
          boosterCards: cards,
          isWanted: (card) => card.id == 'sa1',
        ),
        closeTo(0.25, 1e-9),
      );
    });

    test('compte une variante brillante comme la carte de base', () {
      const foilRates = SetPullRates(
        setId: 'A4b',
        variants: [
          PackVariantPullRates(
            name: 'Regular Pack',
            appearanceRate: 1,
            slots: [
              SlotPullRates({'C': 0.6, 'CF': 0.4}),
            ],
          ),
        ],
      );
      final cards = [_card('c1', 'C')];
      expect(
        calculator.compute(
          pullRates: foilRates,
          boosterCards: cards,
          isWanted: (_) => true,
        ),
        closeTo(1, 1e-9),
      );
    });

    test('ignore une rareté absente du booster', () {
      // Aucune SR dans ce booster : seul le slot commun compte.
      final cards = [_card('c1', 'C')];
      expect(
        calculator.compute(
          pullRates: _rates(),
          boosterCards: cards,
          isWanted: (_) => true,
        ),
        closeTo(1.5, 1e-9),
      );
    });
  });
}
