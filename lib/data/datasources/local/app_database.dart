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
@DriftDatabase(tables: [CardSets, Cards, OwnedCards, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur utilisé par les tests, pour injecter une
  /// connexion (par exemple en mémoire) sans toucher au disque.
  AppDatabase.withExecutor(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, AppConstants.databaseFileName));
      return NativeDatabase.createInBackground(file);
    });
  }
}