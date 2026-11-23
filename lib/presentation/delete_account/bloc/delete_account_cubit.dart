import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_cloud_account.dart';
import 'delete_account_state.dart';

/// ViewModel de la popup de suppression du compte cloud.
///
/// Délègue tout l'enchaînement (confirmation, cloud, compte, données
/// locales) à [DeleteCloudAccount]. Une fois le compte supprimé,
/// `AuthBloc` repasse de lui-même à « déconnecté » par le flux
/// `authStateChanges`. Enregistré en `registerFactory`, une instance
/// par popup.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit({required DeleteCloudAccount deleteCloudAccount})
      : _deleteCloudAccount = deleteCloudAccount,
        super(const DeleteAccountState());

  final DeleteCloudAccount _deleteCloudAccount;

  /// Supprime le compte [userId]. [password] confirme l'identité ;
  /// `null` passe par Google. Ignoré tant qu'une suppression est en
  /// cours.
  Future<void> delete({
    required String userId,
    String? password,
    bool deleteLocalData = false,
  }) async {
    if (state.isDeleting) return;
    emit(const DeleteAccountState(status: DeleteAccountStatus.deleting));
    final result = await _deleteCloudAccount(
      DeleteCloudAccountParams(
        userId: userId,
        password: password,
        deleteLocalData: deleteLocalData,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        DeleteAccountState(
          status: DeleteAccountStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        const DeleteAccountState(status: DeleteAccountStatus.success),
      ),
    );
  }
}
