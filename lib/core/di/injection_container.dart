import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/card_local_data_source.dart';
import '../../data/datasources/remote/card_remote_data_source.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import '../network/network_info.dart';

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
  sl.registerLazySingleton<Connectivity>(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
  sl.registerLazySingleton<http.Client>(http.Client.new);

  // Data sources
  sl.registerLazySingleton<CardRemoteDataSource>(
    () => CardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CardLocalDataSource>(
    () => CardLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  // TODO: enregistrer les use cases (SyncCardCatalog, GetCardSets,
  // GetCardsBySet, GetOwnedCardIds, SetCardOwned).

  // Blocs / Cubits
  // TODO: enregistrer les Blocs (factory, une instance par écran).
}