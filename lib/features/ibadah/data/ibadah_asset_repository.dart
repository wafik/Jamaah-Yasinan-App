import 'dart:convert';

import 'package:flutter/services.dart';

import 'ibadah_asset_models.dart';

class IbadahAssetRepository {
  IbadahAssetRepository._();

  static final IbadahAssetRepository instance = IbadahAssetRepository._();

  static const Map<String, List<String>> suratAssetGroups =
      <String, List<String>>{
        'almulk': <String>['assets/json/surat/almulk.json'],
        'arrahman': <String>['assets/json/surat/arrahman.json'],
        'waqiah': <String>['assets/json/surat/waqiah.json'],
        'yasin': <String>['assets/json/surat/yasin.json'],
        'alkahfi': <String>[
          'assets/json/surat/alkahfi-1-100.json',
          'assets/json/surat/alkahfi-101-110.json',
        ],
      };

  final Map<String, dynamic> _cache = <String, dynamic>{};

  Future<SurahAsset> loadSurah(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached is SurahAsset) return cached;

    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final surah = SurahAsset.fromMap(assetPath, json);
      _cache[assetPath] = surah;
      return surah;
    } catch (e) {
      throw Exception('Failed to load $assetPath: $e');
    }
  }

  Future<SurahAsset> loadSurahSource(String source) async {
    if (source.endsWith('.json')) {
      return loadSurah(source);
    }
    return loadSurahGroup(source);
  }

  Future<List<SurahAsset>> loadSuratPilihan() async {
    return Future.wait(<Future<SurahAsset>>[
      loadSurahGroup('almulk'),
      loadSurahGroup('arrahman'),
      loadSurahGroup('waqiah'),
      loadSurahGroup('yasin'),
      loadSurahGroup('alkahfi'),
    ]);
  }

  Future<SurahAsset> loadSurahGroup(String key) async {
    final cached = _cache[key];
    if (cached is SurahAsset) return cached;

    final assetPaths = suratAssetGroups[key] ?? <String>[];
    final parts = await Future.wait(assetPaths.map(loadSurah));
    final merged = parts.length == 1
        ? parts.first
        : SurahAsset.merge(key, parts);
    _cache[key] = merged;
    return merged;
  }

  Future<KitabAsset> loadArbain() async {
    const assetPath = 'assets/json/kitab/arbain.json';
    final cached = _cache[assetPath];
    if (cached is KitabAsset) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              KitabEntryAsset.fromMap(item as Map<String, dynamic>),
        )
        .toList();

    final kitab = KitabAsset(
      assetPath: assetPath,
      title: 'Arbain Nawawi',
      description: 'Kumpulan hadits pilihan Imam Nawawi',
      totalEntries: data.length,
      entries: data,
    );

    _cache[assetPath] = kitab;
    return kitab;
  }

  Future<List<AsmaAsset>> loadAsmaulHusna() async {
    const assetPath = 'assets/json/doa/asmaul-husna.json';
    final cached = _cache[assetPath];
    if (cached is List<AsmaAsset>) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final items = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => AsmaAsset.fromMap(item as Map<String, dynamic>))
        .toList();
    _cache[assetPath] = items;
    return items;
  }
}
