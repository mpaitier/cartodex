import 'package:drift/drift.dart';

import '../../../core/error/exceptions.dart';
import '../../models/account_model.dart';
import 'app_database.dart';

/// Accès à la base locale pour tout ce qui concerne les comptes.
///
/// Comme [CardLocalDataSource][card_local_data_source.dart], lève
/// des [CacheException] en cas d'erreur ; charge au repository de
/// les convertir en [Failure][../../../core/error/failures.dart].
abstract class AccountLocalDataSource {
  Future<List<AccountModel>> getAccounts();

  /// Crée un compte. Devine lui-même s'il doit être principal (s'il
  /// n'existe encore aucun compte) : c'est une règle de stockage,
  /// pas une décision que l'appelant devrait porter.
  Future<void> addAccount({
    required String name,
    required String gameAccountId,
  });

  Future<void> setPrimaryAccount(String accountId);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  const AccountLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<AccountModel>> getAccounts() async {
    try {
      final query = _database.select(_database.accounts)
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
      final rows = await query.get();
      return rows.map(_fromRow).toList();
    } on Exception catch (e) {
      throw CacheException('Échec de la lecture des comptes : $e');
    }
  }

  @override
  Future<void> addAccount({
    required String name,
    required String gameAccountId,
  }) async {
    try {
      final hasAccounts = await (_database.select(_database.accounts)
            ..limit(1))
          .get()
          .then((rows) => rows.isNotEmpty);
      await _database.into(_database.accounts).insert(
            AccountsCompanion.insert(
              name: name,
              gameAccountId: gameAccountId,
              isPrimary: Value(!hasAccounts),
            ),
          );
    } on Exception catch (e) {
      throw CacheException('Échec de la création du compte : $e');
    }
  }

  @override
  Future<void> setPrimaryAccount(String accountId) async {
    try {
      final id = int.parse(accountId);
      // Il n'y a jamais deux comptes principaux à la fois : on
      // retire d'abord le statut à tous, puis on l'accorde au
      // compte choisi, dans une même transaction.
      await _database.transaction(() async {
        await _database
            .update(_database.accounts)
            .write(const AccountsCompanion(isPrimary: Value(false)));
        await (_database.update(_database.accounts)
              ..where((t) => t.id.equals(id)))
            .write(const AccountsCompanion(isPrimary: Value(true)));
      });
    } on Exception catch (e) {
      throw CacheException('Échec du changement de compte principal : $e');
    }
  }

  AccountModel _fromRow(AccountRow row) {
    return AccountModel(
      id: row.id.toString(),
      name: row.name,
      gameAccountId: row.gameAccountId,
      isPrimary: row.isPrimary,
    );
  }
}