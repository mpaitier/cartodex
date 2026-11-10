import 'package:cartodex/core/config/build_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildConfig.parseUserIds', () {
    test('vide sans réglage', () {
      expect(BuildConfig.parseUserIds(''), isEmpty);
    });

    test('découpe sur les virgules et retire les espaces', () {
      expect(
        BuildConfig.parseUserIds(' abc , def,,ghi '),
        {'abc', 'def', 'ghi'},
      );
    });
  });
}
