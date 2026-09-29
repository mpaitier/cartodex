import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cloud_account.dart';

/// DTO du compte cloud, tel que lu depuis un document Firestore
/// `users/{userId}/accounts/{accountId}` — voir
/// [CloudSyncRepositoryImpl][../repositories/cloud_sync_repository_impl.dart]
/// pour la forme exacte du document.
class CloudAccountModel extends CloudAccount {
  const CloudAccountModel({
    required super.id,
    required super.name,
    required super.gameAccountId,
    required super.isPrimary,
    required super.createdAt,
    required super.ownedCardIds,
  });

  factory CloudAccountModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawOwnedIds = data['ownedCardIds'] as List<dynamic>?;
    return CloudAccountModel(
      id: id,
      name: data['name'] as String? ?? '',
      gameAccountId: data['gameAccountId'] as String? ?? '',
      isPrimary: data['isPrimary'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownedCardIds: rawOwnedIds?.cast<String>().toSet() ?? const {},
    );
  }
}