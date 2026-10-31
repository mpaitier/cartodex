import 'package:equatable/equatable.dart';

/// Un onglet du filtre par série : une page du
/// [SeriesSetsPager][../widgets/series_sets_pager.dart], un bouton de
/// [SeriesFilterBar][../widgets/series_filter_bar.dart] et une tuile
/// de [SeriesPickerSheet][../widgets/series_picker_sheet.dart].
///
/// [key] vaut soit une clé de série (ex: "A", pour tous les sets de
/// série principale de cette série), soit l'une des deux clés des
/// sections spéciales : [deluxeKey] pour les boosters Deluxe,
/// [promoKey] pour tous les sets hors série.
class SeriesTab extends Equatable {
  const SeriesTab({required this.key, required this.label});

  /// Clé réservée à la section "Deluxe". Comme [promoKey], ne peut
  /// pas entrer en collision avec une vraie clé de série, qui fait
  /// une seule lettre (voir `CardSet.isMainSeries`).
  static const String deluxeKey = 'DELUXE';

  /// Clé réservée à l'onglet "Promo".
  static const String promoKey = 'PROMO';

  final String key;
  final String label;

  bool get isDeluxe => key == deluxeKey;

  bool get isPromo => key == promoKey;

  /// Vrai pour une section spéciale ("Deluxe", "Promo"), par
  /// opposition à une série lettrée. Les sections spéciales sont
  /// toujours visibles dans la barre du bas et ont un libellé plus
  /// long qu'une simple lettre.
  bool get isSpecial => isDeluxe || isPromo;

  @override
  List<Object?> get props => [key, label];
}