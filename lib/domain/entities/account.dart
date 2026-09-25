import 'package:equatable/equatable.dart';

/// Représente un compte de jeu suivi par l'application.
///
/// Cartodex peut suivre la collection de plusieurs comptes TCG
/// Pocket (le sien, ceux de proches...). Un seul est "principal" à
/// la fois : c'est celui que la possession d'une carte affecte par
/// défaut (tap simple), les autres n'étant modifiés qu'en le
/// choisissant explicitement (double-tap).
class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.gameAccountId,
    required this.isPrimary,
  });

  /// Identifiant local (généré par l'app), utilisé pour toute
  /// référence interne (ex: possession d'une carte par ce compte).
  final String id;

  final String name;

  /// Identifiant du compte tel que fourni par l'utilisateur (ex:
  /// code ami TCG Pocket). Jamais affiché dans l'UI : seulement
  /// stocké, en vue d'un usage futur (partage, vérification...).
  final String gameAccountId;

  /// Au plus un compte est principal à la fois. Le premier compte
  /// créé l'est automatiquement ; le rôle se déplace ensuite d'un
  /// compte à l'autre (jamais dupliqué ni retiré sans remplaçant).
  final bool isPrimary;

  @override
  List<Object?> get props => [id, name, gameAccountId, isPrimary];
}