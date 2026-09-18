import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/local/account_local_data_source.dart';

/// Implémentation de [AccountRepository].
///
/// N'existe que pour convertir les [CacheException] du datasource
/// local en [Failure] : il n'y a pas de logique métier propre au
/// repository ici, contrairement à
/// [CardRepositoryImpl][card_repository_impl.dart].
class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._localDataSource);

  final AccountLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final accounts = await _localDataSource.getAccounts();
      return Right(accounts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addAccount({
    required String name,
    required String gameAccountId,
  }) async {
    try {
      await _localDataSource.addAccount(
        name: name,
        gameAccountId: gameAccountId,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimaryAccount(String accountId) async {
    try {
      await _localDataSource.setPrimaryAccount(accountId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}