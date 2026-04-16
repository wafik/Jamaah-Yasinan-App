class Agenda {
  const Agenda({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.description,
    this.organizerId,
    this.organizerName,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String? description;
  final int? organizerId;
  final String? organizerName;
  final DateTime createdAt;

  String get dateFormatted {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Agenda copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? description,
    int? organizerId,
    String? organizerName,
    DateTime? createdAt,
  }) {
    return Agenda(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'location': location,
      'description': description,
      'organizer_id': organizerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Agenda.fromMap(Map<String, Object?> map) {
    return Agenda(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      time: map['time'] as String? ?? '',
      location: map['location'] as String? ?? '',
      description: map['description'] as String?,
      organizerId: map['organizer_id'] as int?,
      organizerName: map['organizer_name'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
