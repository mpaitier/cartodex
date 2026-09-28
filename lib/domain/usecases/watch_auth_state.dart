import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Observe l'état de connexion au compte applicatif.
///
/// Ne suit pas le contrat [UseCase][../usecase.dart] (basé sur
/// `Future`) : c'est un flux continu, pas un appel ponctuel — voir
/// son utilisation dans [AuthBloc][../../presentation/auth/bloc/auth_bloc.dart].
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.authStateChanges;
}