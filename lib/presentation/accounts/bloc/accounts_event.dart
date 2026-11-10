import 'package:equatable/equatable.dart';

import '../../../domain/entities/accounts_sort_option.dart';

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

/// Déclenché par le choix d'un critère dans le panneau de tri de la
/// liste des comptes. Le choix est mémorisé pour les lancements
/// suivants.
class AccountsSortChanged extends AccountsEvent {
  const AccountsSortChanged(this.option);

  final AccountsSortOption option;

  @override
  List<Object?> get props => [option];
}

/// Déclenché par le choix d'une extension dans le panneau de tri et
/// de filtre : n'affiche que les comptes qui y ont des cartes en plus.
/// `null` retire le filtre.
class AccountsSetFilterChanged extends AccountsEvent {
  const AccountsSetFilterChanged(this.setId);

  final String? setId;

  @override
  List<Object?> get props => [setId];
}

/// Déclenché par la validation du formulaire d'ajout de compte.
class AccountAdded extends AccountsEvent {
  const AccountAdded({required this.name, required this.gameAccountId});

  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [name, gameAccountId];
}

/// Déclenché par la validation du formulaire de modification d'un
/// compte (bouton crayon de la liste).
class AccountEdited extends AccountsEvent {
  const AccountEdited({
    required this.accountId,
    required this.name,
    required this.gameAccountId,
  });

  final String accountId;
  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [accountId, name, gameAccountId];
}

/// Déclenché par un appui sur la couronne d'un compte secondaire :
/// l'échange avec le principal actuel.
class PrimaryAccountChanged extends AccountsEvent {
  const PrimaryAccountChanged(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}