import 'package:equatable/equatable.dart';

/// Utilisateur du compte applicatif (Firebase).
///
/// À ne pas confondre avec [Account][account.dart], qui représente
/// un compte de jeu Pokémon suivi localement : un compte applicatif
/// est destiné à en synchroniser plusieurs, une fois la
/// synchronisation elle-même en place.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.hasPasswordSignIn = false,
  });

  final String uid;
  final String? email;
  final String? displayName;

  /// `true` quand le compte peut se connecter par email et mot de
  /// passe. Un compte créé uniquement avec Google n'en a pas encore :
  /// l'écran des paramètres propose alors « Définir un mot de passe »
  /// au lieu de « Changer le mot de passe ».
  final bool hasPasswordSignIn;

  @override
  List<Object?> get props => [uid, email, displayName, hasPasswordSignIn];
}
