import 'package:cartodex/core/error/failures.dart';
import 'package:cartodex/domain/entities/accounts_sort_option.dart';
import 'package:cartodex/domain/entities/app_language.dart';
import 'package:cartodex/domain/repositories/user_preferences_repository.dart';
import 'package:cartodex/domain/usecases/get_app_language.dart';
import 'package:cartodex/domain/usecases/save_app_language.dart';
import 'package:cartodex/presentation/language/bloc/language_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux dépôt de préférences, en mémoire. [failing] fait échouer
/// toutes les lectures et écritures de langue.
class _FakePreferencesRepository implements UserPreferencesRepository {
  _FakePreferencesRepository({this.stored, this.failing = false});

  AppLanguage? stored;
  final bool failing;

  @override
  Future<Either<Failure, AppLanguage?>> getAppLanguage() async {
    if (failing) return const Left(CacheFailure('lecture impossible'));
    return Right(stored);
  }

  @override
  Future<Either<Failure, void>> saveAppLanguage(AppLanguage language) async {
    if (failing) return const Left(CacheFailure('écriture impossible'));
    stored = language;
    return const Right(null);
  }

  @override
  Future<Either<Failure, AccountsSortOption?>> getAccountsSortOption() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveAccountsSortOption(
    AccountsSortOption option,
  ) async =>
      const Right(null);
}

LanguageCubit _cubit(_FakePreferencesRepository repository) => LanguageCubit(
      getAppLanguage: GetAppLanguage(repository),
      saveAppLanguage: SaveAppLanguage(repository),
    );

void main() {
  group('LanguageCubit', () {
    test('démarre sur la langue du téléphone', () {
      final cubit = _cubit(_FakePreferencesRepository());
      addTearDown(cubit.close);
      expect(cubit.state, AppLanguage.system);
    });

    test('load relit la langue enregistrée', () async {
      final cubit = _cubit(
        _FakePreferencesRepository(stored: AppLanguage.english),
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state, AppLanguage.english);
    });

    test('load sans choix enregistré reste sur le téléphone', () async {
      final cubit = _cubit(_FakePreferencesRepository());
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state, AppLanguage.system);
    });

    test('load en échec reste sur le téléphone', () async {
      final cubit = _cubit(_FakePreferencesRepository(failing: true));
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state, AppLanguage.system);
    });

    test('select change la langue et l’enregistre', () async {
      final repository = _FakePreferencesRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);
      await cubit.select(AppLanguage.french);
      expect(cubit.state, AppLanguage.french);
      expect(repository.stored, AppLanguage.french);
    });

    test('select garde la langue choisie même si l’enregistrement échoue',
        () async {
      final cubit = _cubit(_FakePreferencesRepository(failing: true));
      addTearDown(cubit.close);
      await cubit.select(AppLanguage.english);
      expect(cubit.state, AppLanguage.english);
    });
  });
}
