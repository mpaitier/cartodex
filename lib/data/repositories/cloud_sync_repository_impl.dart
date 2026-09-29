import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/cloud_account.dart';
import '../../domain/repositories/cloud_sync_repository.dart';
import '../models/cloud_account_model.dart';

/// Implémentation de [CloudSyncRepository] au-dessus de Firestore.
///
/// Un document par compte Pokémon
/// (`users/{userId}/accounts/{accountId}`), avec les cartes
/// possédées dans un champ tableau `ownedCardIds` : une
/// synchronisation coûte une lecture par compte, pas une par carte.
/// [pushAccount] utilise `arrayUnion` pour ce champ, jamais un
/// remplacement complet — c'est ce qui garantit, même côté
/// Firestore, que "possédée" l'emporte toujours sur "non possédée".
///
/// Règles de sécurité Firestore attendues (à déployer côté
/// console) :
/// ```
/// match /users/{userId}/accounts/{accountId} {
///   allow read, write: if request.auth != null
///     && request.auth.uid == userId;
/// }
/// ```
class CloudSyncRepositoryImpl implements CloudSyncRepository {
  const CloudSyncRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _accountsCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  @override
  Future<Either<Failure, List<CloudAccount>>> fetchAccounts(
    String userId,
  ) async {
    try {
      final snapshot = await _accountsCollection(userId).get();
      final accounts = snapshot.docs
          .map((doc) => CloudAccountModel.fromFirestore(doc.id, doc.data()))
          .toList();
      return Right(accounts);
    } on Exception catch (e) {
      return Left(ServerFailure('Échec de la lecture des comptes cloud : $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pushAccount({
    required String userId,
    required CloudAccount account,
  }) async {
    try {
      await _accountsCollection(userId).doc(account.id).set({
        'name': account.name,
        'gameAccountId': account.gameAccountId,
        'isPrimary': account.isPrimary,
        'createdAt': Timestamp.fromDate(account.createdAt),
        // arrayUnion, jamais un remplacement : une carte déjà
        // présente côté cloud n'est jamais retirée par cet envoi,
        // même si `ownedCardIds` ici n'est qu'une différence
        // partielle (voir SyncWithCloud, qui n'envoie que ce qui
        // manque au cloud).
        if (account.ownedCardIds.isNotEmpty)
          'ownedCardIds': FieldValue.arrayUnion(account.ownedCardIds.toList()),
      }, SetOptions(merge: true));
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Échec de l\'envoi du compte au cloud : $e'));
    }
  }
}