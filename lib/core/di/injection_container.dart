import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/card_local_data_source.dart';
import '../../data/datasources/remote/card_remote_data_source.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/get_cards.dart';
import '../../domain/usecases/get_cards_by_set.dart';
import '../../domain/usecases/get_owned_cards_id.dart';
import '../../domain/usecases/set_card_owned.dart';
import '../../domain/usecases/sync_card_catalog.dart';
import '../../presentation/card_sets/bloc/card_sets_bloc.dart';
import '../../presentation/set_detail/bloc/set_detail_bloc.dart';
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
  sl.registerLazySingleton(() => SyncCardCatalog(sl()));
  sl.registerLazySingleton(() => GetCardSets(sl()));
  sl.registerLazySingleton(() => GetCardsBySet(sl()));
  sl.registerLazySingleton(() => GetOwnedCardIds(sl()));
  sl.registerLazySingleton(() => SetCardOwned(sl()));

  // Blocs / Cubits
  sl.registerFactory(
    () => CardSetsBloc(
      getCardSets: sl(),
      syncCardCatalog: sl(),
    ),
  );
  sl.registerFactory(
    () => SetDetailBloc(
      getCardsBySet: sl(),
      getOwnedCardIds: sl(),
      setCardOwned: sl(),
    ),
  );
}