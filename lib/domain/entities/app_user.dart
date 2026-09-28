import 'package:equatable/equatable.dart';

/// Utilisateur du compte applicatif (Firebase).
///
/// À ne pas confondre avec [Account][account.dart], qui représente
/// un compte de jeu Pokémon suivi localement : un compte applicatif
/// est destiné à en synchroniser plusieurs, une fois la
/// synchronisation elle-même en place.
class AppUser extends Equatable {
  const AppUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}