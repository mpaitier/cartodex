import 'package:equatable/equatable.dart';

import 'series_tab.dart';

/// Résumé d'une série pour
/// [SeriesPickerSheet][../widgets/series_picker_sheet.dart] : combien
/// de sets elle contient, et où en est le compte principal sur
/// l'ensemble de ces sets.
///
/// Calculé par `CardSetsState.seriesOverviews` à partir de la
/// progression déjà chargée pour les tuiles : aucun appel
/// supplémentaire au repository.
class SeriesOverview extends Equatable {
  const SeriesOverview({
    required this.tab,
    required this.setCount,
    required this.primaryOwned,
    required this.total,
  });

  final SeriesTab tab;
  final int setCount;

  /// Cartes de la série possédées par le compte principal, toutes
  /// raretés confondues (losanges et cartes alternatives).
  final int primaryOwned;

  /// Nombre de cartes de la série prises en compte. Vaut 0 tant
  /// qu'aucun compte principal n'existe : la progression n'a alors
  /// pas de sens et n'est pas affichée (voir [hasProgress]).
  final int total;

  bool get hasProgress => total > 0;

  double get primaryRatio => total == 0 ? 0 : primaryOwned / total;

  /// Vrai quand le compte principal, à lui seul, possède toute la
  /// série. Même règle que pour les tuiles de set : les secondaires
  /// ne suffisent pas à rendre une série "complète".
  bool get isPrimaryComplete => total > 0 && primaryOwned >= total;

  @override
  List<Object?> get props => [tab, setCount, primaryOwned, total];
}