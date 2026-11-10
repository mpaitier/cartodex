/// Mise en forme des pourcentages de progression.
///
/// Ne renvoie que le nombre (ex: "34,28") : le signe % et l'espace
/// qui le précède ou non dépendent de la langue, ils sont ajoutés par
/// la présentation (clé `percentValue` des fichiers ARB). Le séparateur
/// décimal aussi : la virgule par défaut, le point pour l'anglais
/// (clé `decimalSeparator`).
///
/// Les valeurs sont arrondies vers le bas, comme le reste de l'app :
/// une série à 2 cartes près ne doit jamais afficher "100,00".
/// Le calcul se fait en entiers pour éviter les écarts d'arrondi des
/// doubles (ex: 29/100 qui donnerait 28,99).
abstract class PercentFormatter {
  /// [part] sur [total] avec deux décimales (ex: 12 / 35 → "34,28",
  /// ou "34.28" avec `decimalSeparator: '.'`).
  ///
  /// [total] doit être strictement positif.
  static String twoDecimals(
    int part,
    int total, {
    String decimalSeparator = ',',
  }) {
    final hundredths = (part * 10000) ~/ total;
    final units = hundredths ~/ 100;
    final decimals = (hundredths % 100).toString().padLeft(2, '0');
    return '$units$decimalSeparator$decimals';
  }
}
