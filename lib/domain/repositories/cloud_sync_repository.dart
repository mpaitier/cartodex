import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/cloud_account.dart';

/// Frontière entre le domaine et le stockage cloud des comptes
/// Pokémon et de leur possession. L'implémentation concrète (couche
/// data) est seule à savoir qu'il s'agit de Firestore.
abstract class CloudSyncRepository {
  /// Récupère tous les comptes de l'utilisateur [userId] depuis le
  /// cloud, avec leurs cartes possédées.
  Future<Either<Failure, List<CloudAccount>>> fetchAccounts(String userId);

  /// Envoie [account] dans le cloud. Les cartes possédées sont
  /// *ajoutées* à celles déjà présentes (union), jamais remplacées :
  /// un envoi ne peut pas faire perdre de progression.
  Future<Either<Failure, void>> pushAccount({
    required String userId,
    required CloudAccount account,
  });
}