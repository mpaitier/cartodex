import 'package:flutter/foundation.dart';

/// Utilitaire de log console, coloré selon le niveau.
///
/// Pensé comme un outil de debug temporaire (ex: vérifier que les
/// URLs d'images reconstruites par l'app sont correctes) plutôt que
/// comme un vrai système de logging applicatif : ne s'exécute
/// jamais en dehors de [kDebugMode], pour ne rien afficher ni
/// coûter en production.
///
/// Format affiché : `[LEVEL] content`, où `[LEVEL]` seul est coloré
/// (le contenu reste en couleur par défaut de la console).
abstract class AppLogger {
  static const String _reset = '\x1B[0m';

  /// Couleur ANSI associée à chaque niveau. Toute chaîne absente de
  /// cette table (niveau custom, faute de frappe...) s'affiche sans
  /// couleur plutôt que de planter.
  static const Map<String, String> _colorByLevel = {
    'INFO': '\x1B[34m', // bleu
    'WARNING': '\x1B[38;5;208m', // orange
    'ERROR': '\x1B[31m', // rouge
    'SUCCESS': '\x1B[32m', // vert
  };

  /// Affiche `[level] content` dans la console, `[level]` coloré
  /// selon [_colorByLevel]. [level] est comparé insensible à la
  /// casse ("info", "Info", "INFO" sont équivalents).
  static void log(String level, String content) {
    if (!kDebugMode) return;
    final normalizedLevel = level.toUpperCase();
    final color = _colorByLevel[normalizedLevel];
    final coloredLevel =
        color == null ? '[$normalizedLevel]' : '$color[$normalizedLevel]$_reset';
    debugPrint('$coloredLevel $content');
  }
}