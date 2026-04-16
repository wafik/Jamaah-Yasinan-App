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
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE jamaahs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            address TEXT NOT NULL,
            neighborhood TEXT NOT NULL,
            role TEXT NOT NULL,
            is_present INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');

        await _seed(db);
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
        isPresent: true,
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Ibu Sari Rahayu',
        phone: '0813-2222-1111',
        address: 'Jl. Kenanga No. 3, Purbalingga',
        neighborhood: 'RT 06',
        role: 'Anggota',
        isPresent: false,
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Ahmad Nurdin',
        phone: '0821-9876-1234',
        address: 'Perum Griya Asri Blok B2',
        neighborhood: 'RT 05',
        role: 'Anggota',
        isPresent: true,
        createdAt: DateTime(2026, 4, 16),
      ),
      JamaahMember(
        name: 'Wati Susanti',
        phone: '0857-1111-2222',
        address: 'Jl. Mawar No. 7, Purbalingga',
        neighborhood: 'RT 07',
        role: 'Bendahara',
        isPresent: true,
        createdAt: DateTime(2026, 4, 16),
      ),
    ];

    for (final item in seed) {
      await db.insert(
        'jamaahs',
        item.copyWith(createdAt: now).toMap()..remove('id'),
      );
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
}
