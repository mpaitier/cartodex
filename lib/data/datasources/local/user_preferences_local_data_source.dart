import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';

/// Accès au stockage clé/valeur de l'appareil (`shared_preferences`)
/// pour les réglages d'affichage de l'utilisateur.
///
/// Ne manipule que des chaînes : la conversion vers les types du
/// domaine (et le repli quand une valeur n'est plus reconnue) se fait
/// dans [UserPreferencesRepositoryImpl][../../repositories/user_preferences_repository_impl.dart].
/// Lève des [CacheException] en cas d'erreur, comme les autres
/// datasources locaux.
abstract class UserPreferencesLocalDataSource {
  /// Nom du critère de tri de la liste des comptes, ou `null` s'il
  /// n'a jamais été enregistré.
  Future<String?> getAccountsSortOption();

  Future<void> saveAccountsSortOption(String value);
}

class UserPreferencesLocalDataSourceImpl
    implements UserPreferencesLocalDataSource {
  const UserPreferencesLocalDataSourceImpl(this._preferences);

  final SharedPreferencesAsync _preferences;

  /// Clé du critère de tri des comptes. Ne jamais la renommer : les
  /// choix déjà enregistrés seraient perdus.
  static const String _accountsSortOptionKey = 'accounts_sort_option';

  @override
  Future<String?> getAccountsSortOption() async {
    try {
      return await _preferences.getString(_accountsSortOptionKey);
    } on Exception catch (e) {
      throw CacheException('Échec de la lecture du tri des comptes : $e');
    }
  }

  @override
  Future<void> saveAccountsSortOption(String value) async {
    try {
      await _preferences.setString(_accountsSortOptionKey, value);
    } on Exception catch (e) {
      throw CacheException(
        "Échec de l'enregistrement du tri des comptes : $e",
      );
    }
  }
}
