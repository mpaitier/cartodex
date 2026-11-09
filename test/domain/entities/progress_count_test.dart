import 'package:cartodex/domain/entities/progress_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressCount.missing', () {
    test('retire les cartes du principal et celles des secondaires', () {
      const progress = ProgressCount(owned: 50, secondaryExtra: 8, total: 70);
      expect(progress.missing, 12);
    });

    test('vaut 0 quand toutes les cartes sont possédées quelque part', () {
      const progress = ProgressCount(owned: 60, secondaryExtra: 10, total: 70);
      expect(progress.missing, 0);
    });

    test('vaut le total quand personne ne possède rien', () {
      const progress = ProgressCount(owned: 0, secondaryExtra: 0, total: 70);
      expect(progress.missing, 70);
    });

    test('ne devient jamais négatif', () {
      const progress = ProgressCount(owned: 70, secondaryExtra: 5, total: 70);
      expect(progress.missing, 0);
    });

    test('suit la somme de deux compteurs', () {
      const a = ProgressCount(owned: 10, secondaryExtra: 2, total: 20);
      const b = ProgressCount(owned: 5, secondaryExtra: 1, total: 10);
      expect((a + b).missing, 12);
    });
  });
}
