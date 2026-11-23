import 'package:equatable/equatable.dart';

/// Étape du cycle de vie de [PasswordResetState].
enum PasswordResetStatus {
  /// Formulaire affiché, rien d'envoyé.
  initial,

  sending,

  /// Lien envoyé à [PasswordResetState.email].
  sent,

  /// Échec de l'envoi, détaillé dans [PasswordResetState.errorMessage].
  failure,
}

/// État de l'envoi d'un email de réinitialisation du mot de passe —
/// voir [PasswordResetCubit][password_reset_cubit.dart].
class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.status = PasswordResetStatus.initial,
    this.email,
    this.errorMessage,
  });

  final PasswordResetStatus status;

  /// Adresse à laquelle le dernier envoi a été demandé.
  final String? email;

  final String? errorMessage;

  bool get isSending => status == PasswordResetStatus.sending;

  @override
  List<Object?> get props => [status, email, errorMessage];
}
