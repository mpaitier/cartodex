import 'package:drift/drift.dart';

/// Table Drift des comptes suivis par l'application.
///
/// [id] est un identifiant unique globalement (UUID v4, généré par
/// [AccountLocalDataSourceImpl][../account_local_data_source.dart])
/// plutôt qu'un entier auto-incrémenté local : un compte peut être
/// créé hors-ligne sur un appareil, puis synchronisé avec Firebase
/// aux côtés d'un autre compte créé hors-ligne sur un second
/// appareil — deux entiers auto-incrémentés locaux pourraient
/// entrer en collision, deux UUID jamais.
///
/// [createdAt] fixe l'ordre d'affichage et sert à déterminer quel
/// compte est le tout premier créé (principal par défaut).
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Identifiant du compte tel que fourni par l'utilisateur (ex:
  /// code ami). Jamais lu ailleurs que dans la couche data : voir
  /// [Account.gameAccountId][../../../../domain/entities/account.dart].
  TextColumn get gameAccountId => text()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}