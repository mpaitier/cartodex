import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../usecase.dart';

/// Connecte le compte applicatif via Google.
class SignInWithGoogle implements UseCase<AppUser, NoParams> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}