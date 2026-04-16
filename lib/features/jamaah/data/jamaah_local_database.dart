import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'jamaah_member.dart';

class JamaahLocalDatabase {
  JamaahLocalDatabase._();

  static final JamaahLocalDatabase instance = JamaahLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = path.join(await getDatabasesPath(), 'ventri_jamaah.db');

    return openDatabase(
      dbPath,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE jamaahs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            address TEXT NOT NULL,
            neighborhood TEXT NOT NULL,
            role TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE almarhum (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Jamaah_id INTEGER NOT NULL,
            Jamaah_name TEXT NOT NULL,
            lineage TEXT,
            death_date TEXT NOT NULL,
            gender TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE prayer_requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Jamaah_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            relation TEXT,
            is_deceased INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await _seed(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE jamaahs DROP COLUMN is_present');
          } catch (_) {}
          try {
            await db.execute('''
              CREATE TABLE almarhum (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                Jamaah_id INTEGER NOT NULL,
                Jamaah_name TEXT NOT NULL,
                lineage TEXT,
                death_date TEXT NOT NULL,
                gender TEXT NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
          } catch (_) {}
        }
        if (oldVersion < 3) {
          try {
            await db.execute('''
              CREATE TABLE prayer_requests (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                Jamaah_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                relation TEXT,
                is_deceased INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
              )
            ''');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now();
    final seed = <JamaahMember>[
      JamaahMember(
        name: 'Bapak Usman',
        phone: '0812-3456-7890',
        address: 'Jl. Melati No. 12, Purbalingga',
        neighborhood: 'RT 05',
        role: 'Ketua Jamaah',
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Ibu Sari Rahayu',
        phone: '0813-2222-1111',
        address: 'Jl. Kenanga No. 3, Purbalingga',
        neighborhood: 'RT 06',
        role: 'Anggota',
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Ahmad Nurdin',
        phone: '0821-9876-1234',
        address: 'Perum Griya Asri Blok B2',
        neighborhood: 'RT 05',
        role: 'Anggota',
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Wati Susanti',
        phone: '0857-1111-2222',
        address: 'Jl. Mawar No. 7, Purbalingga',
        neighborhood: 'RT 07',
        role: 'Bendahara',
        createdAt: DateTime(2026, 4, 16),
      ),
    ];

    for (final item in seed) {
      await db.insert(
        'jamaahs',
        item.copyWith(createdAt: now).toMap()..remove('id'),
      );
    }

    final almarhumSeed = <Almarhum>[
      Almarhum(
        jamaahId: 5,
        jamaahName: 'H. Ahmad Wijaya',
        lineage: 'Bin H. Salim',
        deathDate: DateTime(2024, 3, 10),
        gender: 'L',
        createdAt: now,
      ),
      Almarhum(
        jamaahId: 6,
        jamaahName: 'H. Budi Santoso',
        lineage: 'Bin H. Suparman',
        deathDate: DateTime(2024, 1, 22),
        gender: 'L',
        createdAt: now,
      ),
      Almarhum(
        jamaahId: 7,
        jamaahName: 'Hj. Siti Rahayu',
        lineage: 'Binti H. Mahmud',
        deathDate: DateTime(2024, 2, 18),
        gender: 'P',
        createdAt: now,
      ),
    ];

    for (final item in almarhumSeed) {
      await db.insert('almarhum', item.toMap()..remove('id'));
    }
  }

  Future<List<JamaahMember>> getAllMembers() async {
    final db = await database;
    final rows = await db.query('jamaahs', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(JamaahMember.fromMap).toList();
  }

  Future<int> insertMember(JamaahMember member) async {
    final db = await database;
    return db.insert('jamaahs', member.toMap()..remove('id'));
  }

  Future<int> updateMember(JamaahMember member) async {
    final db = await database;
    return db.update(
      'jamaahs',
      member.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return db.delete('jamaahs', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<Almarhum>> getAllAlmarhum() async {
    final db = await database;
    final rows = await db.query('almarhum', orderBy: 'death_date DESC');
    return rows.map(Almarhum.fromMap).toList();
  }

  Future<List<Almarhum>> getAlmarhumByGender(String gender) async {
    final db = await database;
    final rows = await db.query(
      'almarhum',
      where: 'gender = ?',
      whereArgs: <Object?>[gender],
      orderBy: 'death_date DESC',
    );
    return rows.map(Almarhum.fromMap).toList();
  }

  Future<int> insertAlmarhum(Almarhum almarhum) async {
    final db = await database;
    return db.insert('almarhum', almarhum.toMap()..remove('id'));
  }

  Future<int> deleteAlmarhum(int id) async {
    final db = await database;
    return db.delete('almarhum', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<int> getAlmarhumCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM almarhum');
    return result.first['count'] as int? ?? 0;
  }

  Future<List<PrayerRequest>> getPrayerRequests(int jamaaId) async {
    final db = await database;
    final rows = await db.query(
      'prayer_requests',
      where: 'jamaah_id = ?',
      whereArgs: <Object?>[jamaaId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(PrayerRequest.fromMap).toList();
  }

  Future<int> insertPrayerRequest(PrayerRequest request) async {
    final db = await database;
    return db.insert('prayer_requests', request.toMap()..remove('id'));
  }

  Future<int> deletePrayerRequest(int id) async {
    final db = await database;
    return db.delete(
      'prayer_requests',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
