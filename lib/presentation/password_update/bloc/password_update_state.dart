import 'package:equatable/equatable.dart';

/// Étape du cycle de vie de [PasswordUpdateState].
enum PasswordUpdateStatus {
  /// Formulaire affiché, rien d'enregistré.
  initial,

  saving,

  /// Mot de passe ajouté ou changé.
  success,

  /// Échec, détaillé dans [PasswordUpdateState.errorMessage].
  failure,
}

/// État du formulaire de mot de passe des paramètres — voir
/// [PasswordUpdateCubit][password_update_cubit.dart].
class PasswordUpdateState extends Equatable {
  const PasswordUpdateState({
    this.status = PasswordUpdateStatus.initial,
    this.errorMessage,
  });

  final PasswordUpdateStatus status;
  final String? errorMessage;

  bool get isSaving => status == PasswordUpdateStatus.saving;

  @override
  List<Object?> get props => [status, errorMessage];
}
