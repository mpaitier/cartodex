import 'package:equatable/equatable.dart';

import '../../../domain/entities/card_set.dart';

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

/// Un onglet du filtre par série (voir
/// [SeriesFilterBar][../widgets/series_filter_bar.dart]).
///
/// [key] identifie ce qu'il faut filtrer : soit une clé de série
/// (ex: "A", pour tous les sets non-promo de cette série), soit
/// l'id d'un set promo précis (ex: "PROMO-B", qui n'a de sens qu'à
/// lui seul).
class SeriesTab extends Equatable {
  const SeriesTab({required this.key, required this.label});

  final String key;
  final String label;

  @override
  List<Object?> get props => [key, label];
}

/// État affiché par l'écran de liste des sets.
class CardSetsState extends Equatable {
  const CardSetsState({
    this.status = CardSetsStatus.initial,
    this.sets = const [],
    this.selectedSeriesKey,
    this.errorMessage,
  });

  final CardSetsStatus status;
  final List<CardSet> sets;

  /// Onglet de série actuellement sélectionné dans
  /// [SeriesFilterBar][../widgets/series_filter_bar.dart]. `null`
  /// tant que les sets n'ont pas encore été chargés une première
  /// fois (voir [CardSetsBloc._reload][../bloc/card_sets_bloc.dart],
  /// qui choisit la série la plus récente par défaut).
  final String? selectedSeriesKey;

  final String? errorMessage;

  /// Les onglets à proposer dans le filtre : un par série non-promo
  /// (label = la clé elle-même, ex: "A"), puis un par set promo
  /// (label = son nom, ex: "Promo B") — toujours après les séries
  /// normales. [sets] étant déjà trié du plus récent au plus ancien
  /// (voir `CardLocalDataSource.getCachedCardSets`), le premier
  /// onglet rencontré pour une série donnée est le bon ordre sans
  /// calcul de date supplémentaire.
  List<SeriesTab> get seriesTabs {
    final letteredKeys = <String>[];
    final promoSets = <CardSet>[];
    for (final set in sets) {
      if (set.isPromo) {
        promoSets.add(set);
      } else if (!letteredKeys.contains(set.seriesId)) {
        letteredKeys.add(set.seriesId);
      }
    }
    return [
      for (final key in letteredKeys) SeriesTab(key: key, label: key),
      for (final promo in promoSets) SeriesTab(key: promo.id, label: promo.name),
    ];
  }

  /// Les sets à afficher dans la grille compte tenu de
  /// [selectedSeriesKey] : tous les sets non-promo de cette série,
  /// ou seulement ce set promo précis si la clé correspond à un
  /// onglet promo.
  List<CardSet> get visibleSets {
    final key = selectedSeriesKey;
    if (key == null) return sets;
    return sets.where((set) {
      if (set.isPromo) return set.id == key;
      return set.seriesId == key;
    }).toList();
  }

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  CardSetsState copyWith({
    CardSetsStatus? status,
    List<CardSet>? sets,
    String? selectedSeriesKey,
    String? errorMessage,
  }) {
    return CardSetsState(
      status: status ?? this.status,
      sets: sets ?? this.sets,
      selectedSeriesKey: selectedSeriesKey ?? this.selectedSeriesKey,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sets, selectedSeriesKey, errorMessage];
}