import 'package:equatable/equatable.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';

/// Étape du cycle de vie de [AccountExtrasState].
enum AccountExtrasStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Calcul des cartes en plus en cours.
  loading,

  /// Calcul terminé (éventuellement sans aucun set).
  loaded,

  /// Échec du calcul.
  error,
}

/// État affiché par l'écran des cartes en plus d'un compte secondaire.
class AccountExtrasState extends Equatable {
  const AccountExtrasState({
    this.status = AccountExtrasStatus.initial,
    this.account,
    this.extras,
    this.uniqueOnly = false,
    this.errorMessage,
  });

  final AccountExtrasStatus status;

  /// Le compte affiché, tenu à jour après une modification de son nom
  /// ou de son code ami depuis cet écran. `null` avant
  /// `AccountExtrasStarted`.
  final Account? account;

  final AccountExtras? extras;

  /// Vrai quand le bouton empreinte de la barre du haut est activé :
  /// la liste ne montre plus les cartes en plus du principal, mais
  /// celles qu'aucun autre compte ne possède.
  final bool uniqueOnly;

  final String? errorMessage;

  /// Les sets à afficher selon le mode courant ([uniqueOnly]).
  List<SetExtras> get visibleSets {
    final current = extras;
    if (current == null) return const [];
    return uniqueOnly ? current.uniqueBySet : current.bySet;
  }

  /// Le total affiché dans l'en-tête, selon le mode courant.
  ExtraCounts get visibleTotals {
    final current = extras;
    if (current == null) return const ExtraCounts();
    return uniqueOnly ? current.uniqueTotals : current.totals;
  }

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  AccountExtrasState copyWith({
    AccountExtrasStatus? status,
    Account? account,
    AccountExtras? extras,
    bool? uniqueOnly,
    String? errorMessage,
  }) {
    return AccountExtrasState(
      status: status ?? this.status,
      account: account ?? this.account,
      extras: extras ?? this.extras,
      uniqueOnly: uniqueOnly ?? this.uniqueOnly,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, account, extras, uniqueOnly, errorMessage];
}