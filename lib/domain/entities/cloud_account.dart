import 'package:equatable/equatable.dart';

/// Un compte Pokémon tel qu'il est stocké dans le cloud, avec les
/// cartes qu'il possède. Sert uniquement à la synchronisation (voir
/// `SyncWithCloud`) : l'application n'affiche jamais cette entité
/// directement, elle manipule [Account] et les ensembles de cartes
/// possédées séparément.
class CloudAccount extends Equatable {
  const CloudAccount({
    required this.id,
    required this.name,
    required this.gameAccountId,
    required this.isPrimary,
    required this.createdAt,
    required this.ownedCardIds,
  });

  final String id;
  final String name;
  final String gameAccountId;
  final bool isPrimary;
  final DateTime createdAt;
  final Set<String> ownedCardIds;

  @override
  List<Object?> get props =>
      [id, name, gameAccountId, isPrimary, createdAt, ownedCardIds];
}