import '../../domain/entities/pack_variant_pull_rates.dart';
import '../../domain/entities/set_pull_rates.dart';
import '../../domain/entities/slot_pull_rates.dart';

/// DTO des probabilités de tirage d'un set, tel que reçu depuis
/// `pullRates.json`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database) ou
/// relu depuis le cache local.
class SetPullRatesModel extends SetPullRates {
  const SetPullRatesModel({required super.setId, required super.variants});

  /// `pullRates.json` est un objet indexé par code de set ; chaque
  /// valeur a cette forme :
  /// ```json
  /// {
  ///   "Regular Pack": {
  ///     "appearance_rate": 99.95,
  ///     "cards": 5,
  ///     "slots": {
  ///       "1": { "C": 100.0 },
  ///       "4": { "UR": 0.04, "IM": 0.222, "SR": 0.5, "U": 90.0 }
  ///     }
  ///   },
  ///   "Rare Pack": { "appearance_rate": 0.05, "cards": 5, "slots": {} }
  /// }
  /// ```
  /// [setId] est la clé de l'objet englobant, fournie par l'appelant
  /// (voir `CardRemoteDataSourceImpl.fetchPullRates`).
  ///
  /// Les pourcentages de la source sont convertis en fractions (99.95
  /// → 0.9995). Les emplacements sont triés par numéro : la source
  /// numérote à partir de 1 ou de 0 selon les boosters, seul l'ordre
  /// compte. Une variante sans emplacement exploitable est ignorée.
  factory SetPullRatesModel.fromJson(
    String setId,
    Map<String, dynamic> json,
  ) {
    final variants = <PackVariantPullRates>[];
    for (final entry in json.entries) {
      final raw = entry.value;
      if (raw is! Map<String, dynamic>) continue;
      final slots = _slotsFromJson(raw['slots']);
      if (slots.isEmpty) continue;
      variants.add(
        PackVariantPullRates(
          name: entry.key,
          appearanceRate: _fraction(raw['appearance_rate']),
          slots: slots,
        ),
      );
    }
    return SetPullRatesModel(setId: setId, variants: variants);
  }

  static List<SlotPullRates> _slotsFromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return const [];
    final keys = raw.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    final slots = <SlotPullRates>[];
    for (final key in keys) {
      final rates = raw[key];
      if (rates is! Map<String, dynamic>) continue;
      slots.add(
        SlotPullRates({
          for (final rate in rates.entries) rate.key: _fraction(rate.value),
        }),
      );
    }
    return slots;
  }

  /// Un pourcentage de la source (nombre, éventuellement entier) en
  /// fraction. Une valeur absente ou illisible vaut 0 plutôt que de
  /// faire échouer toute la synchronisation.
  static double _fraction(Object? percent) {
    if (percent is num) return percent.toDouble() / 100;
    return 0;
  }
}
