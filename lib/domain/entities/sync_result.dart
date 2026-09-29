import 'package:equatable/equatable.dart';

/// Bilan d'une synchronisation avec le cloud, pour informer
/// l'utilisateur de ce qui a bougé.
class SyncResult extends Equatable {
  const SyncResult({
    this.accountsPulled = 0,
    this.accountsPushed = 0,
    this.cardsPulled = 0,
    this.cardsPushed = 0,
  });

  /// Comptes qui n'existaient que dans le cloud, importés en local.
  final int accountsPulled;

  /// Comptes qui n'existaient qu'en local, envoyés dans le cloud.
  final int accountsPushed;

  /// Cartes possédées dans le cloud mais pas en local, ajoutées en
  /// local (hors comptes importés en entier).
  final int cardsPulled;

  /// Cartes possédées en local mais pas dans le cloud, envoyées.
  final int cardsPushed;

  /// Vrai quand rien n'a changé d'aucun côté.
  bool get isEmpty =>
      accountsPulled == 0 &&
      accountsPushed == 0 &&
      cardsPulled == 0 &&
      cardsPushed == 0;

  @override
  List<Object?> get props =>
      [accountsPulled, accountsPushed, cardsPulled, cardsPushed];
}