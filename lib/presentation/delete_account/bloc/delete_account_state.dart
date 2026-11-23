import 'package:equatable/equatable.dart';

/// Étape du cycle de vie de [DeleteAccountState].
enum DeleteAccountStatus {
  /// Popup affichée, rien de supprimé.
  initial,

  deleting,

  /// Compte et données supprimés.
  success,

  /// Échec, détaillé dans [DeleteAccountState.errorMessage].
  failure,
}

/// État de la popup de suppression du compte cloud — voir
/// [DeleteAccountCubit][delete_account_cubit.dart].
class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.errorMessage,
  });

  final DeleteAccountStatus status;
  final String? errorMessage;

  bool get isDeleting => status == DeleteAccountStatus.deleting;

  @override
  List<Object?> get props => [status, errorMessage];
}
