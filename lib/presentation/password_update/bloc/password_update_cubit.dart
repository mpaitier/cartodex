import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/usecases/change_password.dart';
import '../../../domain/usecases/link_password.dart';
import 'password_update_state.dart';

/// ViewModel du formulaire de mot de passe des paramètres, pour un
/// compte cloud connecté :
///
/// - [linkPassword] ajoute un mot de passe à un compte créé avec
///   Google, qui peut ensuite se connecter des deux façons ;
/// - [changePassword] remplace le mot de passe d'un compte qui en a
///   déjà un.
///
/// Le nouvel état de l'utilisateur (avec mot de passe) remonte tout
/// seul à `AuthBloc` par le flux `authStateChanges` du dépôt.
/// Enregistré en `registerFactory`, une instance par formulaire.
class PasswordUpdateCubit extends Cubit<PasswordUpdateState> {
  PasswordUpdateCubit({
    required LinkPassword linkPassword,
    required ChangePassword changePassword,
  })  : _linkPassword = linkPassword,
        _changePassword = changePassword,
        super(const PasswordUpdateState());

  final LinkPassword _linkPassword;
  final ChangePassword _changePassword;

  /// Ignoré tant qu'un enregistrement est en cours.
  Future<void> linkPassword(String password) async {
    if (state.isSaving) return;
    emit(const PasswordUpdateState(status: PasswordUpdateStatus.saving));
    final result = await _linkPassword(LinkPasswordParams(password: password));
    _emitResult(result);
  }

  /// Ignoré tant qu'un enregistrement est en cours.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.isSaving) return;
    emit(const PasswordUpdateState(status: PasswordUpdateStatus.saving));
    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    _emitResult(result);
  }

  void _emitResult<T>(Either<Failure, T> result) {
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PasswordUpdateState(
          status: PasswordUpdateStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        const PasswordUpdateState(status: PasswordUpdateStatus.success),
      ),
    );
  }
}
