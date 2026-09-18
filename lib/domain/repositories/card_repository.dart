import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/card_set.dart';
import '../entities/pokemon_card.dart';

/// Frontière entre le domaine et la donnée pour tout ce qui
/// concerne les cartes.
///
/// Deux responsabilités bien séparées, comme décrit dans le
/// README :
/// - le référentiel de cartes (sets, cartes, synchronisation),
///   dont la source de vérité est l'API TCGdex ;
/// - la possession de chaque carte, dont la source de vérité est
///   uniquement la base locale Drift.
///
/// L'implémentation concrète (couche data) est la seule à savoir
/// qu'il existe deux datasources distincts derrière cette
/// interface.
abstract class CardRepository {
  /// Télécharge (ou met à jour) le référentiel de cartes TCG
  /// Pocket depuis TCGdex et le persiste en local. N'affecte jamais
  /// les cartes marquées comme possédées.
  Future<Either<Failure, void>> syncCardCatalog();

  /// Retourne tous les sets déjà synchronisés en local.
  Future<Either<Failure, List<CardSet>>> getCardSets();

  /// Retourne toutes les cartes d'un set déjà synchronisées en
  /// local.
  Future<Either<Failure, List<PokemonCard>>> getCardsBySet(String setId);

  /// Retourne les identifiants de toutes les cartes marquées comme
  /// possédées par l'utilisateur.
  Future<Either<Failure, Set<String>>> getOwnedCardIds();

  /// Marque (ou démarque) une carte comme possédée. N'appelle
  /// jamais l'API : écrit uniquement en local.
  Future<Either<Failure, void>> setCardOwned(String cardId, bool owned);
}