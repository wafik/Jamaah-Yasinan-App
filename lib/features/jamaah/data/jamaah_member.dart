class JamaahMember {
  JamaahMember({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.neighborhood,
    required this.role,
    required this.createdAt,
  });

  int? id;
  final String name;
  final String phone;
  final String address;
  final String neighborhood;
  final String role;
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

  JamaahMember copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? neighborhood,
    String? role,
    DateTime? createdAt,
  }) {
    return JamaahMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      role: role ?? this.role,
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
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class Almarhum {
  Almarhum({
    this.id,
    required this.jamaahId,
    required this.jamaahName,
    this.lineage,
    required this.deathDate,
    required this.gender,
    required this.createdAt,
  });

  final int? id;
  final int jamaahId;
  final String jamaahName;
  final String? lineage;
  final DateTime deathDate;
  final String gender;
  final DateTime createdAt;

  String get deathDateFormatted {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${deathDate.day} ${months[deathDate.month - 1]} ${deathDate.year}';
  }

  String get initials {
    final parts = jamaahName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AL';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'jamaah_id': jamaahId,
      'jamaah_name': jamaahName,
      'lineage': lineage,
      'death_date': deathDate.toIso8601String().split('T').first,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Almarhum.fromMap(Map<String, Object?> map) {
    return Almarhum(
      id: map['id'] as int?,
      jamaahId: map['jamaah_id'] as int? ?? 0,
      jamaahName: map['jamaah_name'] as String? ?? '',
      lineage: map['lineage'] as String?,
      deathDate:
          DateTime.tryParse(map['death_date'] as String? ?? '') ??
          DateTime.now(),
      gender: map['gender'] as String? ?? 'L',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class PrayerRequest {
  PrayerRequest({
    this.id,
    this.jamaahId,
    required this.name,
    this.relation,
    required this.isDeceased,
    required this.createdAt,
  });

  int? id;
  int? jamaahId;
  final String name;
  final String? relation;
  final bool isDeceased;
  final DateTime createdAt;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'PR';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'jamaah_id': jamaahId,
      'name': name,
      'relation': relation,
      'is_deceased': isDeceased ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PrayerRequest.fromMap(Map<String, Object?> map) {
    return PrayerRequest(
      id: map['id'] as int?,
      jamaahId: map['jamaah_id'] as int?,
      name: map['name'] as String? ?? '',
      relation: map['relation'] as String?,
      isDeceased: (map['is_deceased'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
