/// Mise en forme des pourcentages de progression, à la française
/// (virgule décimale, espace avant le signe %).
///
/// Les valeurs sont arrondies vers le bas, comme le reste de l'app :
/// une série à 2 cartes près ne doit jamais afficher "100,00 %".
/// Le calcul se fait en entiers pour éviter les écarts d'arrondi des
/// doubles (ex: 29/100 qui donnerait 28,99).
abstract class PercentFormatter {
  /// [part] sur [total] avec deux décimales (ex: 12 / 35 → "34,28 %").
  ///
  /// [total] doit être strictement positif.
  static String twoDecimals(int part, int total) {
    final hundredths = (part * 10000) ~/ total;
    final units = hundredths ~/ 100;
    final decimals = (hundredths % 100).toString().padLeft(2, '0');
    return '$units,$decimals %';
  }
}
