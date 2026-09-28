import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../usecase.dart';

/// Crée le compte applicatif par email et mot de passe.
class SignUpWithEmail implements UseCase<AppUser, SignUpWithEmailParams> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignUpWithEmailParams params) {
    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

/// Paramètres attendus par [SignUpWithEmail].
class SignUpWithEmailParams extends Equatable {
  const SignUpWithEmailParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}