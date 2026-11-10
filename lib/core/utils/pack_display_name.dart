/// Nom d'un booster tel qu'affiché dans l'app, sans le nom de son
/// extension quand le référentiel l'y a répété.
///
/// Certaines extensions récentes préfixent le nom de leurs boosters
/// par le leur (extension "Dual Fusion" → booster "Dual Fusion Mega
/// Mewtwo X") : sur une puce de filtre déjà affichée dans le détail
/// de ce set, la répétition n'apporte rien. Les noms sans ce préfixe
/// ("Mewtwo" dans "Genetic Apex") restent tels quels.
///
/// Affichage uniquement : le nom brut reste la valeur de filtre et
/// sert à retrouver l'icône du booster.
abstract class PackDisplayName {
  /// [packName] sans le préfixe "[setName] ". Renvoie [packName] tel
  /// quel s'il ne commence pas par ce préfixe, ou si le retirer ne
  /// laisserait rien.
  static String of(String setName, String packName) {
    final prefix = '$setName ';
    if (!packName.startsWith(prefix)) return packName;
    final stripped = packName.substring(prefix.length).trim();
    return stripped.isEmpty ? packName : stripped;
  }
}
