import '../../domain/entities/account.dart';

/// DTO du compte, tel que relu depuis le cache local. Il n'y a pas
/// de source distante classique pour les comptes (la synchronisation
/// cloud passe par `CloudAccountModel`/`CloudSyncRepository`) : pas
/// de `fromJson` ici, contrairement à [CardModel][card_model.dart].
class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.gameAccountId,
    required super.isPrimary,
    required super.createdAt,
  });
}