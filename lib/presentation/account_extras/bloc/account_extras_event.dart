import 'package:equatable/equatable.dart';

/// Événements gérés par [AccountExtrasBloc][account_extras_bloc.dart].
abstract class AccountExtrasEvent extends Equatable {
  const AccountExtrasEvent();

  @override
  List<Object?> get props => [];
}

/// Déclenché à l'ouverture de l'écran : calcule les cartes que le
/// compte secondaire [accountId] possède en plus du principal.
class AccountExtrasStarted extends AccountExtrasEvent {
  const AccountExtrasStarted(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

/// Déclenché au retour du détail d'un set, où la possession a pu
/// changer : recalcule sans repasser par un état de chargement.
class AccountExtrasRefreshRequested extends AccountExtrasEvent {
  const AccountExtrasRefreshRequested(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}