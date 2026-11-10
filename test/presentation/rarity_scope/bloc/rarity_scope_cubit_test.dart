import 'package:cartodex/core/constants/card_rarities.dart';
import 'package:cartodex/domain/entities/rarity_scope.dart';
import 'package:cartodex/presentation/rarity_scope/bloc/rarity_scope_card_group.dart';
import 'package:cartodex/presentation/rarity_scope/bloc/rarity_scope_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RarityScopeCubit', () {
    late RarityScopeCubit cubit;

    setUp(() => cubit = RarityScopeCubit());
    tearDown(() => cubit.close());

    test('démarre sur Σ (toutes les raretés)', () {
      expect(cubit.state, RarityScope.all);
    });

    test('cycle : Σ → losange → étoile → Σ', () {
      cubit.cycle();
      expect(cubit.state, RarityScope.diamond);
      cubit.cycle();
      expect(cubit.state, RarityScope.star);
      cubit.cycle();
      expect(cubit.state, RarityScope.all);
    });

    test('select fixe directement le périmètre', () {
      cubit.select(RarityScope.star);
      expect(cubit.state, RarityScope.star);
    });

    test("select n'émet rien si le périmètre ne change pas", () async {
      final emitted = <RarityScope>[];
      final subscription = cubit.stream.listen(emitted.add);

      cubit.select(RarityScope.all);
      cubit.select(RarityScope.diamond);
      cubit.select(RarityScope.diamond);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [RarityScope.diamond]);
      await subscription.cancel();
    });
  });

  group('Correspondance périmètre ↔ volet du détail de set', () {
    test('chaque périmètre a son volet', () {
      expect(RarityScope.all.cardGroup, CardGroupFilter.all);
      expect(RarityScope.diamond.cardGroup, CardGroupFilter.diamond);
      expect(RarityScope.star.cardGroup, CardGroupFilter.nonDiamond);
    });

    test('aller-retour sans perte', () {
      for (final scope in RarityScope.values) {
        expect(scope.cardGroup.rarityScope, scope);
      }
      for (final group in CardGroupFilter.values) {
        expect(group.rarityScope.cardGroup, group);
      }
    });
  });
}
