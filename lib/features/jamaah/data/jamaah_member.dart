class JamaahMember {
  const JamaahMember({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.neighborhood,
    required this.role,
    required this.isPresent,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String phone;
  final String address;
  final String neighborhood;
  final String role;
  final bool isPresent;
  final DateTime createdAt;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'JM';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String get detail => '$neighborhood • $role';

  String get status => isPresent ? 'Hadir' : 'Izin';

  JamaahMember copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? neighborhood,
    String? role,
    bool? isPresent,
    DateTime? createdAt,
  }) {
    return JamaahMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      role: role ?? this.role,
      isPresent: isPresent ?? this.isPresent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'neighborhood': neighborhood,
      'role': role,
      'is_present': isPresent ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory JamaahMember.fromMap(Map<String, Object?> map) {
    return JamaahMember(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      role: map['role'] as String? ?? '',
      isPresent: (map['is_present'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
