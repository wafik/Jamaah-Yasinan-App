class SurahAyahAsset {
  const SurahAyahAsset({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int number;
  final String arabic;
  final String translation;

  factory SurahAyahAsset.fromMap(Map<String, dynamic> map) {
    return SurahAyahAsset(
      number: map['ayah_number'] as int? ?? 0,
      arabic: map['arab'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
    );
  }
}

class SurahAsset {
  const SurahAsset({
    required this.assetPath,
    required this.number,
    required this.name,
    required this.latinName,
    required this.ayahCount,
    required this.translation,
    required this.revelation,
    required this.description,
    required this.ayahs,
  });

  final String assetPath;
  final int number;
  final String name;
  final String latinName;
  final int ayahCount;
  final String translation;
  final String revelation;
  final String description;
  final List<SurahAyahAsset> ayahs;

  String get listSubtitle => 'Ayat $ayahCount • $translation';

  factory SurahAsset.merge(String assetPath, List<SurahAsset> parts) {
    final first = parts.first;
    final mergedAyahs = parts.expand((SurahAsset item) => item.ayahs).toList()
      ..sort(
        (SurahAyahAsset a, SurahAyahAsset b) => a.number.compareTo(b.number),
      );

    return SurahAsset(
      assetPath: assetPath,
      number: first.number,
      name: first.name,
      latinName: first.latinName,
      ayahCount: first.ayahCount,
      translation: first.translation,
      revelation: first.revelation,
      description: first.description,
      ayahs: mergedAyahs,
    );
  }

  factory SurahAsset.fromMap(String assetPath, Map<String, dynamic> root) {
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final ayahs = (data['ayahs'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              SurahAyahAsset.fromMap(item as Map<String, dynamic>),
        )
        .toList();

    return SurahAsset(
      assetPath: assetPath,
      number: data['number'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      latinName: data['name_latin'] as String? ?? '',
      ayahCount: data['number_of_ayahs'] as int? ?? 0,
      translation: data['translation'] as String? ?? '',
      revelation: data['revelation'] as String? ?? '',
      description: data['description'] as String? ?? '',
      ayahs: ayahs,
    );
  }
}

class KitabEntryAsset {
  const KitabEntryAsset({
    required this.number,
    required this.title,
    required this.arabic,
    required this.translation,
  });

  final String number;
  final String title;
  final String arabic;
  final String translation;

  factory KitabEntryAsset.fromMap(Map<String, dynamic> map) {
    return KitabEntryAsset(
      number: map['no'] as String? ?? '',
      title: map['judul'] as String? ?? '',
      arabic: map['arab'] as String? ?? '',
      translation: map['indo'] as String? ?? '',
    );
  }
}

class KitabAsset {
  const KitabAsset({
    required this.assetPath,
    required this.title,
    required this.description,
    required this.totalEntries,
    required this.entries,
  });

  final String assetPath;
  final String title;
  final String description;
  final int totalEntries;
  final List<KitabEntryAsset> entries;

  String get listSubtitle => '$totalEntries Hadits • $description';
}

class AsmaAsset {
  const AsmaAsset({
    required this.order,
    required this.latin,
    required this.arabic,
    required this.meaning,
  });

  final int order;
  final String latin;
  final String arabic;
  final String meaning;

  String get numberLabel => order.toString().padLeft(2, '0');
  String get description =>
      '$latin berarti $meaning. Data dimuat dari aset lokal aplikasi.';

  factory AsmaAsset.fromMap(Map<String, dynamic> map) {
    return AsmaAsset(
      order: map['urutan'] as int? ?? 0,
      latin: map['latin'] as String? ?? '',
      arabic: map['arab'] as String? ?? '',
      meaning: map['arti'] as String? ?? '',
    );
  }
}
