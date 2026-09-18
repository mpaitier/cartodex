import 'package:equatable/equatable.dart';

/// Événements gérés par [AccountsBloc][accounts_bloc.dart].
abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran.
class AccountsStarted extends AccountsEvent {
  const AccountsStarted();
}

/// Déclenché par la validation du formulaire d'ajout de compte.
class AccountAdded extends AccountsEvent {
  const AccountAdded({required this.name, required this.gameAccountId});

  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [name, gameAccountId];
}

/// Déclenché par un appui sur la couronne d'un compte secondaire :
/// l'échange avec le principal actuel.
class PrimaryAccountChanged extends AccountsEvent {
  const PrimaryAccountChanged(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}