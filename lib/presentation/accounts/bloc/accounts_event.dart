import 'package:equatable/equatable.dart';

import 'accounts_sort_option.dart';

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

/// Déclenché au retour d'un écran où la possession a pu changer
/// (détail d'un compte secondaire, puis d'un set) : recalcule la
/// liste et les cartes en plus de chaque secondaire, sans repasser
/// par un état de chargement.
class AccountsRefreshRequested extends AccountsEvent {
  const AccountsRefreshRequested();
}

/// Déclenché par le choix d'un critère dans le menu de tri de la
/// liste des comptes.
class AccountsSortChanged extends AccountsEvent {
  const AccountsSortChanged(this.option);

  final AccountsSortOption option;

  @override
  List<Object?> get props => [option];
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