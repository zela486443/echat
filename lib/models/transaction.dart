import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('transfer') transfer,
  @JsonValue('deposit') deposit,
  @JsonValue('withdrawal') withdrawal,
  @JsonValue('payment') payment,
  @JsonValue('split') split,
}

enum TransactionStatus {
  @JsonValue('pending') pending,
  @JsonValue('completed') completed,
  @JsonValue('failed') failed,
  @JsonValue('cancelled') cancelled,
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(name: 'sender_id') String? senderId,
    @JsonKey(name: 'receiver_id') String? receiverId,
    required double amount,
    required String currency,
    @JsonKey(name: 'transaction_type') required TransactionType transactionType,
    required TransactionStatus status,
    String? description,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

@freezed
class WalletBalance with _$WalletBalance {
  const factory WalletBalance({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required double balance,
    required String currency,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WalletBalance;

  factory WalletBalance.fromJson(Map<String, dynamic> json) => _$WalletBalanceFromJson(json);
}
