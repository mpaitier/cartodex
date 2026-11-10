import 'package:equatable/equatable.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/progress_count.dart';
import '../../../domain/entities/rarity_scope.dart';
import '../../../domain/entities/set_category.dart';
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

  /// Nombre de séries lettrées toujours visibles dans
  /// [SeriesFilterBar][../widgets/series_filter_bar.dart] (les plus
  /// récentes). Les plus anciennes restent accessibles par le swipe
  /// et par le bouton "Toutes les séries". Les sections spéciales
  /// (Deluxe, Promo) ne comptent pas dans ce nombre : elles sont
  /// toujours affichées.
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
  /// série lettrée (label = la clé elle-même, ex: "A"), de la plus
  /// récente à la plus ancienne, puis "Deluxe" pour les boosters
  /// Deluxe, puis "Promo" pour tous les sets hors série, toujours en
  /// dernier.
  ///
  /// [sets] étant déjà trié du plus récent au plus ancien (voir
  /// `CardLocalDataSource.getCachedCardSets`), l'ordre de première
  /// rencontre d'une série suffit, sans calcul de date.
  List<SeriesTab> get seriesTabs {
    final letteredKeys = <String>[];
    var hasDeluxe = false;
    var hasPromo = false;
    for (final set in sets) {
      switch (set.category) {
        case SetCategory.main:
          if (!letteredKeys.contains(set.seriesId)) {
            letteredKeys.add(set.seriesId);
          }
        case SetCategory.deluxe:
          hasDeluxe = true;
        case SetCategory.promo:
          hasPromo = true;
      }
    }
    return [
      for (final key in letteredKeys) SeriesTab(key: key, label: key),
      if (hasDeluxe)
        const SeriesTab(key: SeriesTab.deluxeKey, label: 'Deluxe'),
      if (hasPromo)
        const SeriesTab(key: SeriesTab.promoKey, label: 'Promo'),
    ];
  }

  /// Les onglets affichés dans la barre du bas : les
  /// [quickSeriesCount] séries lettrées les plus récentes, puis la
  /// série sélectionnée si elle est plus ancienne (pour que la barre
  /// montre toujours où l'on se trouve), puis les sections spéciales
  /// ("Deluxe", "Promo").
  List<SeriesTab> get quickTabs {
    final lettered = <SeriesTab>[];
    final special = <SeriesTab>[];
    for (final tab in seriesTabs) {
      if (tab.isSpecial) {
        special.add(tab);
      } else {
        lettered.add(tab);
      }
    }
    final quick = lettered.take(quickSeriesCount).toList();
    for (final tab in lettered.skip(quickSeriesCount)) {
      if (tab.key == selectedSeriesKey) quick.add(tab);
    }
    return [...quick, ...special];
  }

  /// Vrai dès qu'au moins une série lettrée ne tient pas dans les
  /// [quickSeriesCount] places fixes de la barre : le bouton "Toutes
  /// les séries" est alors affiché. Ne dépend pas de la sélection,
  /// pour que le bouton ne disparaisse pas d'un swipe à l'autre.
  bool get hasHiddenSeries =>
      seriesTabs.where((tab) => !tab.isSpecial).length > quickSeriesCount;

  /// Les sets d'un onglet : les sets de série principale de
  /// [seriesKey], ou tous les boosters Deluxe pour
  /// [SeriesTab.deluxeKey], ou tous les sets hors série pour
  /// [SeriesTab.promoKey].
  List<CardSet> setsForSeries(String seriesKey) {
    if (seriesKey == SeriesTab.deluxeKey) {
      return sets.where((set) => set.category == SetCategory.deluxe).toList();
    }
    if (seriesKey == SeriesTab.promoKey) {
      return sets.where((set) => set.category == SetCategory.promo).toList();
    }
    return sets
        .where(
          (set) =>
              set.category == SetCategory.main && set.seriesId == seriesKey,
        )
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
  /// [SeriesPickerSheet][../widgets/series_picker_sheet.dart], limité
  /// aux cartes du périmètre de raretés global [scope].
  List<SeriesOverview> seriesOverviews(RarityScope scope) => [
        for (final tab in seriesTabs) _overviewFor(tab, scope),
      ];

  SeriesOverview _overviewFor(SeriesTab tab, RarityScope scope) {
    final seriesSets = setsForSeries(tab.key);
    var primaryOwned = 0;
    var total = 0;
    for (final set in seriesSets) {
      final progress = progressBySetId[set.id];
      if (progress == null) continue;
      final count = _scopedProgress(progress, scope);
      primaryOwned += count.owned;
      total += count.total;
    }
    return SeriesOverview(
      tab: tab,
      setCount: seriesSets.length,
      primaryOwned: primaryOwned,
      total: total,
    );
  }

  /// Progression d'une série pour son bandeau, dans le périmètre de
  /// raretés global [scope] : "X (+Y) / Z", avec X pour le compte
  /// principal et Y ce que les secondaires ajoutent.
  ///
  /// Additionne la progression déjà chargée pour les tuiles
  /// ([progressBySetId]) : aucun appel supplémentaire au repository.
  /// `null` tant qu'aucun set de la série n'a de progression (pas
  /// encore de compte principal) : le bandeau n'a alors rien à
  /// montrer.
  ProgressCount? seriesProgressFor(String seriesKey, RarityScope scope) {
    ProgressCount? sum;
    for (final set in setsForSeries(seriesKey)) {
      final progress = progressBySetId[set.id];
      if (progress == null) continue;
      sum = (sum ?? ProgressCount.zero) + _scopedProgress(progress, scope);
    }
    return sum;
  }

  /// La part de [progress] qui entre dans [scope] : les losanges, les
  /// cartes alternatives, ou les deux.
  static ProgressCount _scopedProgress(
    SetProgress progress,
    RarityScope scope,
  ) {
    switch (scope) {
      case RarityScope.all:
        return _countOf(progress.base) + _countOf(progress.alternative);
      case RarityScope.diamond:
        return _countOf(progress.base);
      case RarityScope.star:
        return _countOf(progress.alternative);
    }
  }

  static ProgressCount _countOf(RarityGroupProgress group) {
    return ProgressCount(
      owned: group.primaryOwned,
      secondaryExtra: group.secondaryExtraOwned,
      total: group.total,
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
  List<Object?> get props => [
        status,
        sets,
        selectedSeriesKey,
        progressBySetId,
        errorMessage,
      ];
}