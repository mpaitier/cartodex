import 'package:equatable/equatable.dart';

/// Un onglet du filtre par série : une page du
/// [SeriesSetsPager][../widgets/series_sets_pager.dart], un bouton de
/// [SeriesFilterBar][../widgets/series_filter_bar.dart] et une tuile
/// de [SeriesPickerSheet][../widgets/series_picker_sheet.dart].
///
/// [key] vaut soit une clé de série (ex: "A", pour tous les sets de
/// série principale de cette série), soit [promoKey] pour l'onglet
/// "Promo" qui regroupe tous les sets hors série.
class SeriesTab extends Equatable {
  const SeriesTab({required this.key, required this.label});

  /// Clé réservée à l'onglet "Promo". Ne peut pas entrer en
  /// collision avec une vraie clé de série, qui fait une seule lettre
  /// (voir `CardSet.isMainSeries`).
  static const String promoKey = 'PROMO';

  final String key;
  final String label;

  bool get isPromo => key == promoKey;

  @override
  List<Object?> get props => [key, label];
}