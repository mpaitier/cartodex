import 'package:cartodex/core/widgets/upper_diagonal_clipper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpperDiagonalClipper', () {
    final path = const UpperDiagonalClipper().getClip(const Size(100, 140));

    test('garde le triangle au-dessus de la diagonale', () {
      expect(path.contains(const Offset(90, 10)), isTrue);
      expect(path.contains(const Offset(60, 40)), isTrue);
    });

    test('laisse le triangle sous la diagonale', () {
      expect(path.contains(const Offset(10, 130)), isFalse);
      expect(path.contains(const Offset(40, 80)), isFalse);
    });
  });
}