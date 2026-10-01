import 'package:equatable/equatable.dart';

import 'card_set.dart';

/// Nombre de cartes, séparées comme partout ailleurs dans l'app :
/// collection de base (losanges) d'un côté, cartes alternatives
/// (étoile, couronne, chromatique, ou sans rareté connue) de l'autre.
class ExtraCounts extends Equatable {
  const ExtraCounts({this.base = 0, this.alternative = 0});

  /// Cartes losange.
  final int base;

  /// Cartes non-losange.
  final int alternative;

  int get total => base + alternative;

  bool get isEmpty => total == 0;

  ExtraCounts operator +(ExtraCounts other) {
    return ExtraCounts(
      base: base + other.base,
      alternative: alternative + other.alternative,
    );
  }

  @override
  List<Object?> get props => [base, alternative];
}

/// Pour un set donné, ce qu'un compte secondaire possède en plus du
/// compte principal : les cartes qu'il a et que le principal n'a pas.
class SetExtras extends Equatable {
  const SetExtras({required this.set, required this.counts});

  final CardSet set;
  final ExtraCounts counts;

  @override
  List<Object?> get props => [set, counts];
}

/// Ce qu'un compte secondaire possède en plus du compte principal,
/// détaillé set par set. Ne contient que les sets où il y a au moins
/// une carte en plus (voir `GetSecondaryAccountsExtras`).
class AccountExtras extends Equatable {
  const AccountExtras({required this.accountId, this.bySet = const []});

  final String accountId;
  final List<SetExtras> bySet;

  /// Somme des cartes en plus, tous sets confondus.
  ExtraCounts get totals => bySet.fold<ExtraCounts>(
        const ExtraCounts(),
        (sum, setExtras) => sum + setExtras.counts,
      );

  @override
  List<Object?> get props => [accountId, bySet];
}