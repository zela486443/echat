// SavingsGoal model — plain Dart (no freezed to avoid build_runner requirement)
class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final String status;
  final DateTime? targetDate;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    this.targetDate,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String? ?? '🎯',
    targetAmount: (json['target_amount'] as num).toDouble(),
    currentAmount: (json['current_amount'] as num? ?? 0).toDouble(),
    status: json['status'] as String? ?? 'active',
    targetDate: json['target_date'] != null ? DateTime.parse(json['target_date'] as String) : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'emoji': emoji,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'status': status,
    'target_date': targetDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  SavingsGoal copyWith({
    String? id, String? userId, String? name, String? emoji,
    double? targetAmount, double? currentAmount, String? status,
    DateTime? targetDate, DateTime? createdAt,
  }) => SavingsGoal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    status: status ?? this.status,
    targetDate: targetDate ?? this.targetDate,
    createdAt: createdAt ?? this.createdAt,
  );
}
