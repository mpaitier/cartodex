import 'package:equatable/equatable.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/set_progress.dart';
import 'series_overview.dart';
import 'series_tab.dart';

/// Étape du cycle de vie de [CardSetsState].
enum CardSetsStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Lecture du référentiel local en cours.
  loading,

  /// Synchronisation avec le référentiel distant en cours. Les
  /// [CardSetsState.sets] affichés restent ceux du chargement
  /// précédent : l'écran ne se vide jamais pendant une
  /// synchronisation.
  syncing,

  /// Sets chargés (éventuellement une liste vide, si aucune
  /// synchronisation n'a jamais été faite).
  loaded,

  /// Échec de chargement ou de synchronisation.
  error,
}

/// État affiché par l'écran de liste des sets.
class CardSetsState extends Equatable {
  const CardSetsState({
    this.status = CardSetsStatus.initial,
    this.sets = const [],
    this.selectedSeriesKey,
    this.progressBySetId = const {},
    this.errorMessage,
  });

  /// Nombre de séries principales toujours visibles dans
  /// [SeriesFilterBar][../widgets/series_filter_bar.dart] (les plus
  /// récentes). Les plus anciennes restent accessibles par le swipe
  /// et par le bouton "Toutes les séries".
  static const int quickSeriesCount = 3;

  final CardSetsStatus status;
  final List<CardSet> sets;

  /// Série actuellement affichée. `null` tant que les sets n'ont pas
  /// encore été chargés une première fois (voir
  /// [CardSetsBloc][card_sets_bloc.dart], qui choisit la série la
  /// plus récente par défaut).
  final String? selectedSeriesKey;

  /// Progression du compte principal (et des secondaires en plus)
  /// pour chaque set, indexée par identifiant de set. Vide tant
  /// qu'aucun compte principal n'existe : les tuiles n'affichent
  /// alors aucune progression.
  final Map<String, SetProgress> progressBySetId;

  final String? errorMessage;

  /// Toutes les séries, dans l'ordre des pages du swipe : une par
  /// série principale (label = la clé elle-même, ex: "A"), de la plus
  /// récente à la plus ancienne, puis un seul onglet "Promo" qui
  /// regroupe tous les sets hors série, toujours en dernier.
  ///
  /// [sets] étant déjà trié du plus récent au plus ancien (voir
  /// `CardLocalDataSource.getCachedCardSets`), l'ordre de première
  /// rencontre d'une série suffit, sans calcul de date.
  List<SeriesTab> get seriesTabs {
    final letteredKeys = <String>[];
    var hasPromo = false;
    for (final set in sets) {
      if (set.isPromo) {
        hasPromo = true;
      } else if (!letteredKeys.contains(set.seriesId)) {
        letteredKeys.add(set.seriesId);
      }
    }
    return [
      for (final key in letteredKeys) SeriesTab(key: key, label: key),
      if (hasPromo)
        const SeriesTab(key: SeriesTab.promoKey, label: 'Promo'),
    ];
  }

  /// Les onglets affichés dans la barre du bas : les
  /// [quickSeriesCount] séries principales les plus récentes, puis la
  /// série sélectionnée si elle est plus ancienne (pour que la barre
  /// montre toujours où l'on se trouve), puis "Promo".
  List<SeriesTab> get quickTabs {
    final lettered = <SeriesTab>[];
    SeriesTab? promo;
    for (final tab in seriesTabs) {
      if (tab.isPromo) {
        promo = tab;
      } else {
        lettered.add(tab);
      }
    }
    final quick = lettered.take(quickSeriesCount).toList();
    for (final tab in lettered.skip(quickSeriesCount)) {
      if (tab.key == selectedSeriesKey) quick.add(tab);
    }
    return [...quick, if (promo != null) promo];
  }

  /// Vrai dès qu'au moins une série principale ne tient pas dans les
  /// [quickSeriesCount] places fixes de la barre : le bouton "Toutes
  /// les séries" est alors affiché. Ne dépend pas de la sélection,
  /// pour que le bouton ne disparaisse pas d'un swipe à l'autre.
  bool get hasHiddenSeries =>
      seriesTabs.where((tab) => !tab.isPromo).length > quickSeriesCount;

  /// Les sets d'une série : tous les sets de série principale de
  /// [seriesKey], ou tous les sets hors série pour
  /// [SeriesTab.promoKey].
  List<CardSet> setsForSeries(String seriesKey) {
    if (seriesKey == SeriesTab.promoKey) {
      return sets.where((set) => set.isPromo).toList();
    }
    return sets
        .where((set) => !set.isPromo && set.seriesId == seriesKey)
        .toList();
  }

  /// Les sets de la série sélectionnée, ou tous les sets tant
  /// qu'aucune série n'est sélectionnée.
  List<CardSet> get visibleSets {
    final key = selectedSeriesKey;
    if (key == null) return sets;
    return setsForSeries(key);
  }

  /// Un résumé par série, dans l'ordre de [seriesTabs], pour
  /// [SeriesPickerSheet][../widgets/series_picker_sheet.dart].
  List<SeriesOverview> get seriesOverviews => [
        for (final tab in seriesTabs) _overviewFor(tab),
      ];

  SeriesOverview _overviewFor(SeriesTab tab) {
    final seriesSets = setsForSeries(tab.key);
    var primaryOwned = 0;
    var total = 0;
    for (final set in seriesSets) {
      final progress = progressBySetId[set.id];
      if (progress == null) continue;
      primaryOwned +=
          progress.base.primaryOwned + progress.alternative.primaryOwned;
      total += progress.base.total + progress.alternative.total;
    }
    return SeriesOverview(
      tab: tab,
      setCount: seriesSets.length,
      primaryOwned: primaryOwned,
      total: total,
    );
  }

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  CardSetsState copyWith({
    CardSetsStatus? status,
    List<CardSet>? sets,
    String? selectedSeriesKey,
    Map<String, SetProgress>? progressBySetId,
    String? errorMessage,
  }) {
    return CardSetsState(
      status: status ?? this.status,
      sets: sets ?? this.sets,
      selectedSeriesKey: selectedSeriesKey ?? this.selectedSeriesKey,
      progressBySetId: progressBySetId ?? this.progressBySetId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, sets, selectedSeriesKey, progressBySetId, errorMessage];
}