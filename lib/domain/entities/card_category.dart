/// Catégorie d'une carte telle que définie par TCGdex : une carte
/// est soit un Pokémon, soit un Dresseur (Trainer), soit une
/// Énergie.
///
/// La conversion depuis la chaîne brute renvoyée par l'API se fait
/// dans la couche data (CardModel), jamais ici : le domaine ne
/// connaît que ces trois valeurs fermées.
enum CardCategory {
  pokemon,
  trainer,
  energy,
}