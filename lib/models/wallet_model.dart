import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @Default(0.0) double balance,
    required String currency,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
