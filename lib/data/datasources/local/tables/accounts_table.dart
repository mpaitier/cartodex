import 'package:drift/drift.dart';

/// Table Drift des comptes suivis par l'application.
///
/// [id] est un entier auto-incrémenté plutôt qu'un UUID généré à la
/// main : aucune dépendance supplémentaire n'est nécessaire, et un
/// entier local suffit puisque ces identifiants ne quittent jamais
/// l'appareil (voir [Account][../../../../domain/entities/account.dart]).
///
/// [createdAt] fixe l'ordre d'affichage et sert à déterminer quel
/// compte est le tout premier créé (principal par défaut).
@DataClassName('AccountRow')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Identifiant du compte tel que fourni par l'utilisateur (ex:
  /// code ami). Jamais lu ailleurs que dans la couche data : voir
  /// [Account.gameAccountId][../../../../domain/entities/account.dart].
  TextColumn get gameAccountId => text()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}