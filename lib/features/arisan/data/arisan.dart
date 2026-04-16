class Arisan {
  const Arisan({
    this.id,
    required this.name,
    required this.amount,
    required this.currentRound,
    required this.totalRounds,
    this.agendaId,
    this.agendaTitle,
    this.description,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final int amount;
  final int currentRound;
  final int totalRounds;
  final int? agendaId;
  final String? agendaTitle;
  final String? description;
  final DateTime createdAt;

  String get amountFormatted {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    }
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  double get progress => totalRounds > 0 ? currentRound / totalRounds : 0;

  Arisan copyWith({
    int? id,
    String? name,
    int? amount,
    int? currentRound,
    int? totalRounds,
    int? agendaId,
    String? agendaTitle,
    String? description,
    DateTime? createdAt,
  }) {
    return Arisan(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      agendaId: agendaId ?? this.agendaId,
      agendaTitle: agendaTitle ?? this.agendaTitle,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'amount': amount,
      'current_round': currentRound,
      'total_rounds': totalRounds,
      'agenda_id': agendaId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Arisan.fromMap(Map<String, Object?> map) {
    return Arisan(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      currentRound: map['current_round'] as int? ?? 0,
      totalRounds: map['total_rounds'] as int? ?? 0,
      agendaId: map['agenda_id'] as int?,
      agendaTitle: map['agenda_title'] as String?,
      description: map['description'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ArisanParticipant {
  const ArisanParticipant({
    this.id,
    required this.arisanId,
    required this.memberId,
    required this.memberName,
    required this.hasPaid,
    required this.wonRound,
    this.paidAt,
  });

  final int? id;
  final int arisanId;
  final int memberId;
  final String memberName;
  final bool hasPaid;
  final int wonRound;
  final DateTime? paidAt;

  ArisanParticipant copyWith({
    int? id,
    int? arisanId,
    int? memberId,
    String? memberName,
    bool? hasPaid,
    int? wonRound,
    DateTime? paidAt,
  }) {
    return ArisanParticipant(
      id: id ?? this.id,
      arisanId: arisanId ?? this.arisanId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      hasPaid: hasPaid ?? this.hasPaid,
      wonRound: wonRound ?? this.wonRound,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'arisan_id': arisanId,
      'member_id': memberId,
      'member_name': memberName,
      'has_paid': hasPaid ? 1 : 0,
      'won_round': wonRound,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  factory ArisanParticipant.fromMap(Map<String, Object?> map) {
    return ArisanParticipant(
      id: map['id'] as int?,
      arisanId: map['arisan_id'] as int? ?? 0,
      memberId: map['member_id'] as int? ?? 0,
      memberName: map['member_name'] as String? ?? '',
      hasPaid: (map['has_paid'] as int? ?? 0) == 1,
      wonRound: map['won_round'] as int? ?? 0,
      paidAt: DateTime.tryParse(map['paid_at'] as String? ?? ''),
    );
  }
}
