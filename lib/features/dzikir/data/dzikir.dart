class Dzikir {
  const Dzikir({
    this.id,
    required this.targetCount,
    required this.currentCount,
    required this.name,
    required this.createdAt,
  });

  final int? id;
  final int targetCount;
  final int currentCount;
  final String name;
  final DateTime createdAt;

  bool get isComplete => currentCount >= targetCount;

  Dzikir copyWith({
    int? id,
    int? targetCount,
    int? currentCount,
    String? name,
    DateTime? createdAt,
  }) {
    return Dzikir(
      id: id ?? this.id,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'target_count': targetCount,
      'current_count': currentCount,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Dzikir.fromMap(Map<String, Object?> map) {
    return Dzikir(
      id: map['id'] as int?,
      targetCount: map['target_count'] as int? ?? 33,
      currentCount: map['current_count'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
