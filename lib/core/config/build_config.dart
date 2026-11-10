/// Réglages fournis au moment du build, avec `--dart-define` ou
/// `--dart-define-from-file` (voir `dart_defines.json.example` à la
/// racine du projet). Ils ne sont jamais écrits dans le dépôt.
///
/// Sans réglage, chaque valeur retombe sur un comportement par défaut
/// sûr : aucune exemption.
abstract class BuildConfig {
  /// Identifiants Firebase (uid) des comptes applicatifs exemptés de la
  /// limite de synchronisations (voir `SyncRateLimit`), séparés par des
  /// virgules : typiquement le compte du développeur.
  static const String _syncQuotaExemptUserIdsRaw =
      String.fromEnvironment('SYNC_QUOTA_EXEMPT_UIDS');

  static Set<String> get syncQuotaExemptUserIds =>
      parseUserIds(_syncQuotaExemptUserIdsRaw);

  /// Découpe une liste d'identifiants séparés par des virgules, en
  /// ignorant les espaces et les entrées vides.
  static Set<String> parseUserIds(String raw) => {
        for (final id in raw.split(','))
          if (id.trim().isNotEmpty) id.trim(),
      };
}
