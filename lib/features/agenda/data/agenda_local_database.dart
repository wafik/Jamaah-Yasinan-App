import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'agenda.dart';

class AgendaLocalDatabase {
  AgendaLocalDatabase._();

  static final AgendaLocalDatabase instance = AgendaLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = path.join(await getDatabasesPath(), 'ventri_agenda.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE agenda (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            location TEXT NOT NULL,
            description TEXT,
            organizer_id INTEGER,
            organizer_name TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now();
    final seed = <Agenda>[
      Agenda(
        title: 'Pengajian RT 05',
        date: now.add(const Duration(days: 3)),
        time: "Ba'da Isya",
        location: 'Masjid Al-Hidayah',
        description: 'Pengajian rutin bulanan untuk warga RT 05',
        createdAt: now,
      ),
      Agenda(
        title: 'Tahlilan Jasro',
        date: now.add(const Duration(days: 10)),
        time: 'Pukul 10.00',
        location: 'Masjid Al-Hidayah',
        description: 'Tahlilan untuk warga yang membutuhkan',
        createdAt: now,
      ),
    ];

    for (final item in seed) {
      await db.insert('agenda', item.toMap()..remove('id'));
    }
  }

  Future<List<Agenda>> getAllAgendas() async {
    final db = await database;
    final rows = await db.query('agenda', orderBy: 'date ASC');
    return rows.map(Agenda.fromMap).toList();
  }

  Future<Agenda?> getAgendaById(int id) async {
    final db = await database;
    final rows = await db.query(
      'agenda',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    if (rows.isEmpty) return null;
    return Agenda.fromMap(rows.first);
  }

  Future<int> insertAgenda(Agenda agenda) async {
    final db = await database;
    return db.insert('agenda', agenda.toMap()..remove('id'));
  }

  Future<int> updateAgenda(Agenda agenda) async {
    final db = await database;
    return db.update(
      'agenda',
      agenda.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[agenda.id],
    );
  }

  Future<int> deleteAgenda(int id) async {
    final db = await database;
    return db.delete('agenda', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<Agenda>> getUpcomingAgendas({int limit = 5}) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows = await db.query(
      'agenda',
      where: 'date >= ?',
      whereArgs: <Object?>[today],
      orderBy: 'date ASC',
      limit: limit,
    );
    return rows.map(Agenda.fromMap).toList();
  }
}
