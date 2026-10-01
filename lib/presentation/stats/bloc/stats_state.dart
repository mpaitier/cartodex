import 'package:equatable/equatable.dart';

import '../../../domain/entities/collection_stats.dart';
import '../../../domain/entities/rarity_scope.dart';

/// Étape du cycle de vie de [StatsState].
enum StatsStatus {
  /// Aucun chargement n'a encore été déclenché.
  initial,

  /// Recherche des comptes et calcul des statistiques en cours.
  loading,

  /// Statistiques calculées.
  loaded,

  /// Aucun compte n'existe encore : rien à calculer.
  noAccount,

  /// Échec du chargement.
  error,
}

/// État affiché par l'écran de statistiques.
class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.initial,
    this.stats,
    this.rarityScope = RarityScope.all,
    this.errorMessage,
  });

  final StatsStatus status;
  final CollectionStats? stats;

  /// Périmètre de raretés des statistiques affichées. Rond (toutes)
  /// par défaut.
  final RarityScope rarityScope;

  final String? errorMessage;

  /// Ne préserve jamais l'ancien message d'erreur : toute
  /// transition qui ne le fournit pas explicitement le réinitialise,
  /// pour ne pas réafficher une erreur déjà résolue.
  StatsState copyWith({
    StatsStatus? status,
    CollectionStats? stats,
    RarityScope? rarityScope,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      rarityScope: rarityScope ?? this.rarityScope,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, rarityScope, errorMessage];
}