import 'package:get_it/get_it.dart';

/// Instance unique du service locator, utilisée dans toute
/// l'application pour résoudre les dépendances.
final GetIt sl = GetIt.instance;

/// Enregistre toutes les dépendances de l'application.
///
/// Les enregistrements sont ajoutés couche par couche au fur et à
/// mesure de leur implémentation : core, puis data (datasources,
/// repositories), puis domain (use cases), puis presentation
/// (Blocs/Cubits). L'ordre respecte le sens des dépendances de la
/// Clean Architecture : chaque couche ne connaît que celles en
/// dessous d'elle.
Future<void> init() async {
  // Core
  // TODO: enregistrer NetworkInfo une fois la connectivité utilisée.
  // TODO: enregistrer la base de données Drift (AppDatabase).

  // Data sources
  // TODO: enregistrer le datasource distant (API TCGdex).
  // TODO: enregistrer le datasource local (DAO Drift).

  // Repositories
  // TODO: enregistrer les implémentations de repository.

  // Use cases
  // TODO: enregistrer les use cases.

  // Blocs / Cubits
  // TODO: enregistrer les Blocs (factory, une instance par écran).
}
