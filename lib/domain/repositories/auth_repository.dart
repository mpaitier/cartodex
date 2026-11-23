import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Frontière entre le domaine et l'authentification du compte
/// applicatif. L'implémentation concrète (couche data) est seule à
/// savoir qu'il s'agit de Firebase Auth.
abstract class AuthRepository {
  /// Émet l'utilisateur courant à chaque changement (connexion,
  /// déconnexion, session restaurée au lancement de l'app). `null`
  /// signifie "déconnecté".
  Stream<AppUser?> get authStateChanges;

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  /// Envoie à [email] un lien pour choisir un nouveau mot de passe.
  ///
  /// [languageCode] (ex: `fr`, `en`) fixe la langue de l'email ;
  /// `null` laisse le service choisir. Un succès ne garantit pas
  /// qu'un compte existe pour cette adresse : le service peut taire
  /// cette information pour ne pas révéler quels emails sont inscrits.
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  });
}
