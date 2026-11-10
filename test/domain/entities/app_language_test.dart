import 'package:cartodex/domain/entities/app_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLanguage.languageCode', () {
    test('null pour la langue du téléphone', () {
      expect(AppLanguage.system.languageCode, isNull);
    });

    test('code ISO 639-1 pour une langue imposée', () {
      expect(AppLanguage.french.languageCode, 'fr');
      expect(AppLanguage.english.languageCode, 'en');
    });
  });
}
