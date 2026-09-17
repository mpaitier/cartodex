import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../core/error/failures.dart';

/// Contrat commun à tous les use cases de l'application.
///
/// [Type] est le type de retour attendu en cas de succès, [Params]
/// le type des paramètres d'entrée. Un use case sans paramètre
/// utilise [NoParams].
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Marqueur utilisé par les use cases qui n'attendent aucun
/// paramètre en entrée.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}