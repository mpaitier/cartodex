import 'package:cartodex/domain/entities/account_extras.dart';
import 'package:cartodex/domain/entities/card_set.dart';
import 'package:flutter_test/flutter_test.dart';

SetExtras _extras(String setId, {int base = 0, int alternative = 0}) =>
    SetExtras(
      set: CardSet(
        id: setId,
        name: setId,
        totalCardCount: 0,
        seriesId: setId.substring(0, 1),
      ),
      counts: ExtraCounts(base: base, alternative: alternative),
    );

List<String> _ids(List<SetExtras> sets) => [for (final s in sets) s.set.id];

void main() {
  group('SetExtras.sortedByCounts', () {
    test('trie par losanges en plus, du plus grand au plus petit', () {
      final sorted = SetExtras.sortedByCounts([
        _extras('A1', base: 2),
        _extras('A2', base: 7),
        _extras('A3', base: 4),
      ]);
      expect(_ids(sorted), ['A2', 'A3', 'A1']);
    });

    test('à losanges égaux, trie par étoiles en plus', () {
      final sorted = SetExtras.sortedByCounts([
        _extras('A1', base: 3, alternative: 1),
        _extras('A2', base: 3, alternative: 5),
        _extras('A3', base: 3),
      ]);
      expect(_ids(sorted), ['A2', 'A1', 'A3']);
    });

    test('les losanges passent avant les étoiles', () {
      final sorted = SetExtras.sortedByCounts([
        _extras('A1', alternative: 9),
        _extras('A2', base: 1),
      ]);
      expect(_ids(sorted), ['A2', 'A1']);
    });

    test("à égalité complète, garde l'ordre d'entrée", () {
      final sorted = SetExtras.sortedByCounts([
        _extras('A1', base: 2, alternative: 1),
        _extras('B1', base: 2, alternative: 1),
        _extras('A2', base: 2, alternative: 1),
        _extras('B2', base: 2, alternative: 1),
      ]);
      expect(_ids(sorted), ['A1', 'B1', 'A2', 'B2']);
    });

    test('ne modifie pas la liste reçue', () {
      final input = [_extras('A1', base: 1), _extras('A2', base: 5)];
      SetExtras.sortedByCounts(input);
      expect(_ids(input), ['A1', 'A2']);
    });
  });
}
