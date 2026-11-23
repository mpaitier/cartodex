import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../usecase.dart';

/// Envoie un email de réinitialisation du mot de passe du compte
/// applicatif.
///
/// Sert aux deux entrées de l'app : « Mot de passe oublié ? » sur
/// l'écran de connexion, et « Changer le mot de passe » dans les
/// paramètres une fois connecté.
class SendPasswordResetEmail
    implements UseCase<void, SendPasswordResetEmailParams> {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(SendPasswordResetEmailParams params) {
    return _repository.sendPasswordResetEmail(
      email: params.email,
      languageCode: params.languageCode,
    );
  }
}

/// Paramètres attendus par [SendPasswordResetEmail].
class SendPasswordResetEmailParams extends Equatable {
  const SendPasswordResetEmailParams({
    required this.email,
    this.languageCode,
  });

  final String email;

  /// Langue de l'email envoyé (ex: `fr`), en général celle de l'app.
  final String? languageCode;

  @override
  List<Object?> get props => [email, languageCode];
}
