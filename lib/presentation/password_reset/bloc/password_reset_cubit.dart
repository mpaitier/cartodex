import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/send_password_reset_email.dart';
import 'password_reset_state.dart';

/// ViewModel de la popup de réinitialisation du mot de passe.
///
/// Séparé d'`AuthBloc` : envoyer un lien ne change pas l'état de
/// connexion, et un statut « envoi en cours » global bloquerait à tort
/// l'écran de connexion. Enregistré en `registerFactory`, une instance
/// par popup.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({required SendPasswordResetEmail sendPasswordResetEmail})
      : _sendPasswordResetEmail = sendPasswordResetEmail,
        super(const PasswordResetState());

  final SendPasswordResetEmail _sendPasswordResetEmail;

  /// Demande l'envoi du lien à [email] (espaces retirés), dans la
  /// langue [languageCode]. Ignoré tant qu'un envoi est en cours.
  Future<void> submit({required String email, String? languageCode}) async {
    if (state.isSending) return;
    final trimmed = email.trim();
    emit(
      PasswordResetState(
        status: PasswordResetStatus.sending,
        email: trimmed,
      ),
    );
    final result = await _sendPasswordResetEmail(
      SendPasswordResetEmailParams(
        email: trimmed,
        languageCode: languageCode,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PasswordResetState(
          status: PasswordResetStatus.failure,
          email: trimmed,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        PasswordResetState(status: PasswordResetStatus.sent, email: trimmed),
      ),
    );
  }
}
