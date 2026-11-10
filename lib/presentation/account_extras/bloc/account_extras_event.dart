import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';

/// Événements gérés par [AccountExtrasBloc][account_extras_bloc.dart].
abstract class AccountExtrasEvent extends Equatable {
  const AccountExtrasEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : calcule les cartes que le
/// compte secondaire [account] possède en plus du principal.
class AccountExtrasStarted extends AccountExtrasEvent {
  const AccountExtrasStarted(this.account);

  final Account account;

  @override
  List<Object?> get props => [account];
}

/// Déclenché par la validation de la popup de modification ouverte
/// par le crayon de la barre du haut : change le nom et le code ami
/// du compte affiché.
class AccountExtrasAccountEdited extends AccountExtrasEvent {
  const AccountExtrasAccountEdited({
    required this.name,
    required this.gameAccountId,
  });

  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [name, gameAccountId];
}

/// Déclenché au retour du détail d'un set, où la possession a pu
/// changer : recalcule sans repasser par un état de chargement.
class AccountExtrasRefreshRequested extends AccountExtrasEvent {
  const AccountExtrasRefreshRequested(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}