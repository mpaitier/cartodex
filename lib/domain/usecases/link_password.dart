import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../usecase.dart';

/// Ajoute un mot de passe au compte applicatif connecté, quand il n'en
/// a pas encore (compte créé avec Google).
///
/// Passe par l'app plutôt que par un lien de réinitialisation : un lien
/// envoyé à un compte sans mot de passe est refusé par Firebase
/// (« lien expiré ou déjà utilisé »).
class LinkPassword implements UseCase<AppUser, LinkPasswordParams> {
  const LinkPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(LinkPasswordParams params) {
    return _repository.linkPassword(password: params.password);
  }
}

/// Paramètres attendus par [LinkPassword].
class LinkPasswordParams extends Equatable {
  const LinkPasswordParams({required this.password});

  final String password;

  @override
  List<Object?> get props => [password];
}
