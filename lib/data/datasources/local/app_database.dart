import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import 'tables/accounts_table.dart';
import 'tables/card_sets_table.dart';
import 'tables/cards_table.dart';
import 'tables/owned_cards_table.dart';

part 'app_database.g.dart';

/// Base de données locale de l'application.
///
/// Regroupe le référentiel de cartes ([CardSets], [Cards]), la
/// possession de chaque carte ([OwnedCards]) et les comptes suivis
/// ([Accounts]).
///
/// Le fichier `app_database.g.dart` est généré par `build_runner` :
/// voir la commande indiquée dans le README, il n'est pas fourni
/// ici.
///
/// Historique du schéma :
/// - v1 : schéma initial (comptes et possession identifiés par des
///   entiers auto-incrémentés).
/// - v2 : `Accounts.id` et `OwnedCards.accountId` deviennent du
///   texte (UUID pour les nouveaux comptes), en vue de la
///   synchronisation multi-appareils. Voir
///   [_migrateAccountIdsToText].
@DriftDatabase(tables: [CardSets, Cards, OwnedCards, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur utilisé par les tests, pour injecter une
  /// connexion (par exemple en mémoire) sans toucher au disque.
  AppDatabase.withExecutor(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await _migrateAccountIdsToText(migrator);
        }
      },
    );
  }

  /// v1 → v2 : `Accounts.id` et `OwnedCards.accountId` passent
  /// d'entiers à du texte.
  ///
  /// SQLite ne sait pas changer le type d'une colonne en place : on
  /// renomme les deux anciennes tables, on crée les nouvelles (au
  /// schéma courant, tel que défini dans `tables/`), on recopie les
  /// lignes en convertissant les identifiants en texte, puis on
  /// supprime les anciennes. Aucune donnée n'est perdue : un compte
  /// d'id `1` devient `"1"`, et la possession qui le référence
  /// suit. Le tout dans une transaction : si une étape échoue, la
  /// base reste dans son état v1.
  ///
  /// Suppose une base v1 dont le reste du schéma est déjà à jour
  /// (colonnes `packs`, `seriesId`...), et les noms de colonnes SQL
  /// par défaut de Drift (snake_case : `game_account_id`,
  /// `is_primary`, `created_at`, `card_id`, `account_id`).
  ///
  /// Les anciens comptes gardent des identifiants du type `"1"`,
  /// `"2"` (pas de vrais UUID) : la future synchronisation devra les
  /// remplacer par des UUID au premier envoi, car deux appareils
  /// peuvent avoir chacun un compte `"1"`.
  Future<void> _migrateAccountIdsToText(Migrator migrator) async {
    await transaction(() async {
      await customStatement('ALTER TABLE accounts RENAME TO accounts_old');
      await customStatement(
        'ALTER TABLE owned_cards RENAME TO owned_cards_old',
      );

      await migrator.createTable(accounts);
      await migrator.createTable(ownedCards);

      await customStatement('''
        INSERT INTO accounts (id, name, game_account_id, is_primary, created_at)
        SELECT CAST(id AS TEXT), name, game_account_id, is_primary, created_at
        FROM accounts_old
      ''');
      await customStatement('''
        INSERT INTO owned_cards (card_id, account_id)
        SELECT card_id, CAST(account_id AS TEXT)
        FROM owned_cards_old
      ''');

      await customStatement('DROP TABLE accounts_old');
      await customStatement('DROP TABLE owned_cards_old');
    });
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, AppConstants.databaseFileName));
      return NativeDatabase.createInBackground(file);
    });
  }
}