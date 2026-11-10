/// Type d'une carte, tel que fourni par `cards.extra.json` (champ
/// `type`) : un Pokémon, ou l'un des types de Dresseur du jeu.
///
/// La conversion depuis la chaîne brute du référentiel se fait dans la
/// couche data (`CardModel`), jamais ici : le domaine ne connaît que
/// ces valeurs fermées.
enum CardCategory {
  pokemon,
  supporter,
  item,
  tool,
  stadium,
  fossil,

  /// Type inconnu : carte absente de `cards.extra.json`, valeur que
  /// l'app ne connaît pas encore, ou carte synchronisée avant que ce
  /// détail ne soit lu. Une synchronisation du référentiel la corrige.
  unknown;

  /// Les types de Dresseur (tout sauf [pokemon] et [unknown]).
  bool get isTrainer => this != pokemon && this != unknown;

  /// Valeur correspondant à [name] (ex: "supporter"), ou [unknown] si
  /// le nom n'est pas reconnu, par exemple une ancienne valeur
  /// ("trainer", "energy") encore stockée en base locale.
  static CardCategory fromName(String? name) {
    for (final category in values) {
      if (category.name == name) return category;
    }
    return unknown;
  }
}
