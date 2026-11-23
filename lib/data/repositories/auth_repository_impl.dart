import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

import '../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

/// Implémentation de [AuthRepository] au-dessus de Firebase Auth
/// (email/mot de passe et Google, réinitialisation du mot de passe
/// par email, ajout et changement du mot de passe d'un compte
/// connecté).
///
/// NOTE : l'API `google_sign_in` (Credential Manager côté Android)
/// est récente et évolue vite ; si le code d'erreur exact renvoyé
/// par `authenticate()` diverge de ce qui est géré ici (ex: pour
/// distinguer une annulation d'une vraie erreur), il faudra ajuster
/// [signInWithGoogle] une fois testé en conditions réelles.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required google_sign_in.GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final google_sign_in.GoogleSignIn _googleSignIn;

  /// `initialize()` ne doit être appelé qu'une fois sur toute la vie
  /// de l'app (voir la doc du package) : ce drapeau évite de le
  /// refaire à chaque tentative de connexion Google.
  bool _googleSignInInitialized = false;

  /// Utilisateur mis à jour sans connexion ni déconnexion (mot de passe
  /// ajouté au compte) : `authStateChanges` de Firebase ne l'émet pas,
  /// alors que l'app doit le savoir pour changer ses libellés.
  final StreamController<AppUser?> _userUpdates =
      StreamController<AppUser?>.broadcast();

  /// Fusion des changements de connexion de Firebase et des mises à
  /// jour de [_userUpdates].
  @override
  Stream<AppUser?> get authStateChanges {
    StreamSubscription<AppUser?>? firebaseSubscription;
    StreamSubscription<AppUser?>? updatesSubscription;
    late final StreamController<AppUser?> controller;
    controller = StreamController<AppUser?>(
      onListen: () {
        firebaseSubscription = _firebaseAuth
            .authStateChanges()
            .map(
              (user) =>
                  user == null ? null : AppUserModel.fromFirebaseUser(user),
            )
            .listen(controller.add, onError: controller.addError);
        updatesSubscription = _userUpdates.stream.listen(controller.add);
      },
      onCancel: () async {
        await firebaseSubscription?.cancel();
        await updatesSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(AppUserModel.fromFirebaseUser(credential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(AppUserModel.fromFirebaseUser(credential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const Left(AuthFailure('Connexion Google incomplète.'));
      }
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return Right(AppUserModel.fromFirebaseUser(userCredential.user!));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception catch (e) {
      // Couvre entre autres l'annulation par l'utilisateur du flux
      // Google (exception levée par google_sign_in) : traitée comme
      // un échec silencieux côté UI plutôt qu'une erreur technique.
      return Left(AuthFailure('Connexion Google interrompue : $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleSignInInitialized) {
        await _googleSignIn.signOut();
      }
      return const Right(null);
    } on Exception {
      return const Left(AuthFailure('Échec de la déconnexion.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
    String? languageCode,
  }) async {
    try {
      // Langue de l'email envoyé par Firebase. Réglée juste avant
      // l'envoi, puisqu'elle a pu changer depuis le dernier appel.
      await _firebaseAuth.setLanguageCode(languageCode);
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception {
      return const Left(
        AuthFailure("Impossible d'envoyer l'email de réinitialisation."),
      );
    }
  }

  @override
  Future<Either<Failure, AppUser>> linkPassword({
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return const Left(AuthFailure('Aucun compte connecté.'));
    }
    try {
      await user.linkWithCredential(
        firebase_auth.EmailAuthProvider.credential(
          email: email,
          password: password,
        ),
      );
      // Relu pour que la liste des fournisseurs contienne bien le mot
      // de passe tout juste ajouté.
      await user.reload();
      final updated =
          AppUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
      _userUpdates.add(updated);
      return Right(updated);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception {
      return const Left(AuthFailure("Impossible d'ajouter le mot de passe."));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return const Left(AuthFailure('Aucun compte connecté.'));
    }
    try {
      await user.reauthenticateWithCredential(
        firebase_auth.EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        ),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return const Left(AuthFailure('Mot de passe actuel incorrect.'));
        default:
          return Left(AuthFailure(_messageFor(e)));
      }
    } on Exception {
      return const Left(AuthFailure('Mot de passe actuel incorrect.'));
    }
    try {
      await user.updatePassword(newPassword);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    } on Exception {
      return const Left(AuthFailure('Impossible de changer le mot de passe.'));
    }
  }

  /// Traduit les codes d'erreur Firebase Auth les plus courants en
  /// messages compréhensibles ; retombe sur un message générique
  /// (avec le code brut) pour les autres.
  ///
  /// Avec la protection contre l'énumération des emails (activée par
  /// défaut sur les projets Firebase récents), `user-not-found` n'est
  /// plus renvoyé à l'envoi d'un lien de réinitialisation : il reste
  /// géré pour les projets où elle est désactivée.
  String _messageFor(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'missing-email':
        return 'Adresse email manquante.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie dans quelques minutes.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'requires-recent-login':
        return 'Reconnecte-toi au compte cloud, puis réessaie.';
      case 'provider-already-linked':
        return 'Ce compte a déjà un mot de passe.';
      case 'credential-already-in-use':
        return 'Cette adresse est déjà utilisée par un autre compte.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Aucune connexion réseau.';
      default:
        return 'Erreur de connexion (${e.code}).';
    }
  }
}