import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../usecase.dart';

/// Connecte le compte applicatif par email et mot de passe.
class SignInWithEmail implements UseCase<AppUser, SignInWithEmailParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignInWithEmailParams params) {
    return _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

/// Paramètres attendus par [SignInWithEmail].
class SignInWithEmailParams extends Equatable {
  const SignInWithEmailParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}