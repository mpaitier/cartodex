import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/exceptions.dart';
import '../../models/account_model.dart';
import 'app_database.dart';

/// Motif d'un identifiant de compte "hérité" : un simple nombre en
/// texte (ex: "1", "2"), tel qu'assigné avant que les comptes ne
/// soient identifiés par UUID — voir
/// [AccountLocalDataSourceImpl.migrateLegacyAccountIds].
final _legacyAccountIdPattern = RegExp(r'^[0-9]+$');

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

  /// Remplace par de vrais UUID les identifiants de compte hérités
  /// (voir [_legacyAccountIdPattern]), et met à jour la possession
  /// qui les référence en conséquence. Sans effet s'il n'y en a
  /// plus.
  Future<void> migrateLegacyAccountIds();

  /// Ajoute un compte venu du cloud, avec son identifiant d'origine.
  /// Sans effet si un compte de même id existe déjà.
  Future<void> importAccount({
    required String id,
    required String name,
    required String gameAccountId,
    required DateTime createdAt,
  });
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
      // Identifiant unique globalement, pas seulement local — voir
      // la documentation de Accounts.id (tables/accounts_table.dart).
      final id = const Uuid().v4();
      await _database.into(_database.accounts).insert(
            AccountsCompanion.insert(
              id: id,
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
      // Il n'y a jamais deux comptes principaux à la fois : on
      // retire d'abord le statut à tous, puis on l'accorde au
      // compte choisi, dans une même transaction.
      await _database.transaction(() async {
        await _database
            .update(_database.accounts)
            .write(const AccountsCompanion(isPrimary: Value(false)));
        await (_database.update(_database.accounts)
              ..where((t) => t.id.equals(accountId)))
            .write(const AccountsCompanion(isPrimary: Value(true)));
      });
    } on Exception catch (e) {
      throw CacheException('Échec du changement de compte principal : $e');
    }
  }

  @override
  Future<void> migrateLegacyAccountIds() async {
    try {
      final rows = await _database.select(_database.accounts).get();
      final legacyRows =
          rows.where((row) => _legacyAccountIdPattern.hasMatch(row.id));
      if (legacyRows.isEmpty) return;

      await _database.transaction(() async {
        for (final row in legacyRows) {
          final newId = const Uuid().v4();
          await (_database.update(_database.accounts)
                ..where((t) => t.id.equals(row.id)))
              .write(AccountsCompanion(id: Value(newId)));
          await (_database.update(_database.ownedCards)
                ..where((t) => t.accountId.equals(row.id)))
              .write(OwnedCardsCompanion(accountId: Value(newId)));
        }
      });
    } on Exception catch (e) {
      throw CacheException(
        'Échec de la migration des identifiants de compte : $e',
      );
    }
  }

  @override
  Future<void> importAccount({
    required String id,
    required String name,
    required String gameAccountId,
    required DateTime createdAt,
  }) async {
    try {
      final existing = await (_database.select(_database.accounts)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (existing != null) return;

      final hasAccounts = await (_database.select(_database.accounts)
            ..limit(1))
          .get()
          .then((rows) => rows.isNotEmpty);
      await _database.into(_database.accounts).insert(
            AccountsCompanion.insert(
              id: id,
              name: name,
              gameAccountId: gameAccountId,
              isPrimary: Value(!hasAccounts),
              createdAt: Value(createdAt),
            ),
          );
    } on Exception catch (e) {
      throw CacheException('Échec de l\'import du compte : $e');
    }
  }

  AccountModel _fromRow(AccountRow row) {
    return AccountModel(
      id: row.id,
      name: row.name,
      gameAccountId: row.gameAccountId,
      isPrimary: row.isPrimary,
      createdAt: row.createdAt,
    );
  }
}