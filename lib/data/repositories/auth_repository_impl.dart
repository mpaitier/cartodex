import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

import '../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

/// Implémentation de [AuthRepository] au-dessus de Firebase Auth
/// (email/mot de passe et Google).
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

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
        );
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

  /// Traduit les codes d'erreur Firebase Auth les plus courants en
  /// messages compréhensibles ; retombe sur un message générique
  /// (avec le code brut) pour les autres.
  String _messageFor(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
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