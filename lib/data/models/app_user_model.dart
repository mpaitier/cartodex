import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/app_user.dart';

/// DTO de l'utilisateur du compte applicatif, construit à partir du
/// `User` de Firebase Auth.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.hasPasswordSignIn,
  });

  /// Identifiant Firebase du fournisseur email / mot de passe.
  static const String _passwordProviderId = 'password';

  factory AppUserModel.fromFirebaseUser(firebase_auth.User user) {
    return AppUserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      hasPasswordSignIn: user.providerData
          .any((info) => info.providerId == _passwordProviderId),
    );
  }
}
