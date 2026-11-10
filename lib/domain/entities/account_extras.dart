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

  /// [sets] triés par losanges en plus (du plus grand au plus petit),
  /// puis par étoiles en plus. À égalité, l'ordre d'entrée est
  /// conservé (tri stable) : passés dans l'ordre du catalogue, deux
  /// sets aux mêmes compteurs restent dans cet ordre.
  ///
  /// Renvoie une nouvelle liste ; [sets] n'est pas modifiée.
  static List<SetExtras> sortedByCounts(List<SetExtras> sets) {
    final indexed = [
      for (var i = 0; i < sets.length; i++) (index: i, extras: sets[i]),
    ];
    indexed.sort((a, b) {
      final byBase = b.extras.counts.base.compareTo(a.extras.counts.base);
      if (byBase != 0) return byBase;
      final byAlternative = b.extras.counts.alternative.compareTo(
        a.extras.counts.alternative,
      );
      if (byAlternative != 0) return byAlternative;
      return a.index.compareTo(b.index);
    });
    return [for (final entry in indexed) entry.extras];
  }

  @override
  List<Object?> get props => [set, counts];
}

/// Ce qu'un compte secondaire possède en plus du compte principal,
/// détaillé set par set. Ne contient que les sets où il y a au moins
/// une carte en plus, triés par losanges puis étoiles en plus (voir
/// `GetSecondaryAccountsExtras` et [SetExtras.sortedByCounts]).
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