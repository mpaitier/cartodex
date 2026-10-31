/// Famille d'un set, qui décide de son regroupement à l'écran
/// (onglets de l'accueil, statistiques par série) :
/// - [main] : set d'une série principale ("A1", "B2a"...), rangé sous
///   sa lettre de série ;
/// - [deluxe] : booster Deluxe ("Deluxe Pack: ex", "Deluxe Pack:
///   Mega"...), regroupé dans une section "Deluxe" quelle que soit sa
///   série d'origine ;
/// - [promo] : tout le reste (promos "PROMO-A", sets au code
///   inhabituel...), regroupé dans "Promo".
///
/// Calculée par `CardSet.category` à partir des données du set,
/// jamais stockée.
enum SetCategory {
  main,
  deluxe,
  promo,
}