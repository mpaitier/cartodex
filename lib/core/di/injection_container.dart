import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/account_local_data_source.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/card_local_data_source.dart';
import '../../data/datasources/local/user_preferences_local_data_source.dart';
import '../../data/datasources/remote/card_remote_data_source.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/cloud_sync_repository_impl.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/cloud_sync_repository.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../domain/usecases/add_account.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/usecases/get_accounts_sort_option.dart';
import '../../domain/usecases/get_app_language.dart';
import '../../domain/usecases/get_cards.dart';
import '../../domain/usecases/get_cards_by_set.dart';
import '../../domain/usecases/get_collection_stats.dart';
import '../../domain/usecases/get_owned_cards_id.dart';
import '../../domain/usecases/get_secondary_accounts_extras.dart';
import '../../domain/usecases/get_sets_progress.dart';
import '../../domain/usecases/get_sync_quota.dart';
import '../../domain/usecases/save_accounts_sort_option.dart';
import '../../domain/usecases/save_app_language.dart';
import '../../domain/usecases/set_card_owned.dart';
import '../../domain/usecases/set_primary_account.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sync_card_catalog.dart';
import '../../domain/usecases/sync_with_cloud.dart';
import '../../domain/usecases/update_account.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../presentation/account_extras/bloc/account_extras_bloc.dart';
import '../../presentation/accounts/bloc/accounts_bloc.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/card_sets/bloc/card_sets_bloc.dart';
import '../../presentation/language/bloc/language_cubit.dart';
import '../../presentation/rarity_scope/bloc/rarity_scope_cubit.dart';
import '../../presentation/set_detail/bloc/set_detail_bloc.dart';
import '../../presentation/stats/bloc/stats_bloc.dart';
import '../../presentation/sync/bloc/sync_bloc.dart';
import '../config/build_config.dart';
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
///
/// Suppose `Firebase.initializeApp()` déjà terminé (voir
/// `main.dart`) : `FirebaseAuth.instance`, `GoogleSignIn.instance`
/// et `FirebaseFirestore.instance` en dépendent.
Future<void> init() async {
  // Core
  sl.registerLazySingleton<Connectivity>(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
  sl.registerLazySingleton<http.Client>(http.Client.new);
  sl.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  sl.registerLazySingleton<google_sign_in.GoogleSignIn>(
    () => google_sign_in.GoogleSignIn.instance,
  );
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<SharedPreferencesAsync>(SharedPreferencesAsync.new);

  // Data sources
  sl.registerLazySingleton<CardRemoteDataSource>(
    () => CardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CardLocalDataSource>(
    () => CardLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserPreferencesLocalDataSource>(
    () => UserPreferencesLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<CloudSyncRepository>(
    () => CloudSyncRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SyncCardCatalog(sl()));
  sl.registerLazySingleton(() => GetCardSets(sl()));
  sl.registerLazySingleton(() => GetCardsBySet(sl()));
  sl.registerLazySingleton(() => GetOwnedCardIds(sl()));
  sl.registerLazySingleton(() => SetCardOwned(sl()));
  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => AddAccount(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => GetAccountsSortOption(sl()));
  sl.registerLazySingleton(() => SaveAccountsSortOption(sl()));
  sl.registerLazySingleton(() => GetAppLanguage(sl()));
  sl.registerLazySingleton(() => SaveAppLanguage(sl()));
  sl.registerLazySingleton(() => SetPrimaryAccount(sl()));
  sl.registerLazySingleton(() => GetCollectionStats(sl()));
  sl.registerLazySingleton(
    () => GetSetsProgress(
      cardRepository: sl(),
      accountRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => GetSecondaryAccountsExtras(
      cardRepository: sl(),
      accountRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => WatchAuthState(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(
    () => SyncWithCloud(
      accountRepository: sl(),
      cardRepository: sl(),
      cloudSyncRepository: sl(),
      userPreferencesRepository: sl(),
      exemptUserIds: BuildConfig.syncQuotaExemptUserIds,
    ),
  );
  sl.registerLazySingleton(
    () => GetSyncQuota(
      sl(),
      exemptUserIds: BuildConfig.syncQuotaExemptUserIds,
    ),
  );

  // Blocs / Cubits
  sl.registerFactory(
    () => CardSetsBloc(
      getCardSets: sl(),
      syncCardCatalog: sl(),
      getSetsProgress: sl(),
    ),
  );
  sl.registerFactory(
    () => SetDetailBloc(
      getCardsBySet: sl(),
      getOwnedCardIds: sl(),
      setCardOwned: sl(),
      getAccounts: sl(),
    ),
  );
  sl.registerFactory(
    () => AccountsBloc(
      getAccounts: sl(),
      addAccount: sl(),
      updateAccount: sl(),
      setPrimaryAccount: sl(),
      getSecondaryAccountsExtras: sl(),
      getAccountsSortOption: sl(),
      saveAccountsSortOption: sl(),
    ),
  );
  sl.registerFactory(
    () => AccountExtrasBloc(
      getSecondaryAccountsExtras: sl(),
      updateAccount: sl(),
    ),
  );
  sl.registerFactory(
    () => StatsBloc(
      getAccounts: sl(),
      getCollectionStats: sl(),
    ),
  );
  sl.registerFactory(
    () => SyncBloc(syncWithCloud: sl(), getSyncQuota: sl()),
  );
  // Singleton, pas factory : un seul état de connexion pour toute
  // l'app, fourni une fois à la racine (voir CartodexApp) plutôt que
  // recréé à chaque écran.
  sl.registerLazySingleton(
    () => AuthBloc(
      watchAuthState: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
    ),
  );
  // Singleton aussi : un seul périmètre de raretés (Σ / losange /
  // étoile) pour toute l'app, fourni à la racine comme AuthBloc.
  sl.registerLazySingleton(RarityScopeCubit.new);
  // Singleton également : une seule langue d'affichage pour toute
  // l'app, relue au démarrage (voir main.dart) et fournie à la racine.
  sl.registerLazySingleton(
    () => LanguageCubit(getAppLanguage: sl(), saveAppLanguage: sl()),
  );
}