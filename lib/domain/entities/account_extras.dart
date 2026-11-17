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

/// Pour un set donné, les cartes qu'un compte secondaire apporte : soit
/// celles qu'il a et que le principal n'a pas, soit celles qu'il est
/// le seul à avoir (voir [AccountExtras]).
class SetExtras extends Equatable {
  const SetExtras({
    required this.set,
    required this.counts,
    this.completesBase = false,
    this.completesAlternative = false,
  });

  final CardSet set;
  final ExtraCounts counts;

  /// Vrai quand les cartes losange comptées pour ce compte suffisent à
  /// compléter les losanges du principal dans ce set : le principal et
  /// ces cartes réunis les ont toutes. Faux si ce compte n'apporte
  /// aucun losange, même si le principal est déjà complet seul : le
  /// mérite n'en revient pas à ce compte.
  final bool completesBase;

  /// Même chose que [completesBase] pour les cartes non-losange.
  final bool completesAlternative;

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
  List<Object?> get props =>
      [set, counts, completesBase, completesAlternative];
}

/// Ce qu'un compte secondaire apporte, détaillé set par set, selon
/// deux points de vue :
/// - [bySet] : les cartes qu'il possède et que le compte principal n'a
///   pas (ses "cartes en plus") ;
/// - [uniqueBySet] : les cartes qu'il est le seul à posséder, aucun
///   autre compte (principal ou secondaire) ne les ayant. C'est un
///   sous-ensemble de [bySet], égal à lui quand il n'existe qu'un seul
///   compte secondaire.
///
/// Les deux listes ne contiennent que les sets où il y a au moins une
/// carte à compter, triés par losanges puis étoiles (voir
/// `GetSecondaryAccountsExtras` et [SetExtras.sortedByCounts]).
class AccountExtras extends Equatable {
  const AccountExtras({
    required this.accountId,
    this.bySet = const [],
    this.uniqueBySet = const [],
  });

  final String accountId;
  final List<SetExtras> bySet;
  final List<SetExtras> uniqueBySet;

  /// Somme des cartes en plus, tous sets confondus.
  ExtraCounts get totals => _sum(bySet);

  /// Somme des cartes uniques, tous sets confondus.
  ExtraCounts get uniqueTotals => _sum(uniqueBySet);

  static ExtraCounts _sum(List<SetExtras> sets) => sets.fold<ExtraCounts>(
        const ExtraCounts(),
        (sum, setExtras) => sum + setExtras.counts,
      );

  @override
  List<Object?> get props => [accountId, bySet, uniqueBySet];
}
