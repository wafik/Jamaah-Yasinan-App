import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'arisan.dart';

class ArisanLocalDatabase {
  ArisanLocalDatabase._();

  static final ArisanLocalDatabase instance = ArisanLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = path.join(await getDatabasesPath(), 'ventri_arisan.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE arisan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            amount INTEGER NOT NULL,
            current_round INTEGER NOT NULL DEFAULT 0,
            total_rounds INTEGER NOT NULL,
            agenda_id INTEGER,
            agenda_title TEXT,
            description TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE arisan_participants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            arisan_id INTEGER NOT NULL,
            member_id INTEGER NOT NULL,
            member_name TEXT NOT NULL,
            has_paid INTEGER NOT NULL DEFAULT 0,
            won_round INTEGER NOT NULL DEFAULT 0,
            paid_at TEXT
          )
        ''');

        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now();

    final arisanId = await db.insert('arisan', {
      'name': 'Arisan RT 05',
      'amount': 150000,
      'current_round': 7,
      'total_rounds': 12,
      'description': 'Arisan rutin bulanan warga RT 05',
      'created_at': now.toIso8601String(),
    });

    await db.insert('arisan_participants', {
      'arisan_id': arisanId,
      'member_id': 1,
      'member_name': 'Bapak Usman',
      'has_paid': 1,
      'won_round': 3,
      'paid_at': now.toIso8601String(),
    });
    await db.insert('arisan_participants', {
      'arisan_id': arisanId,
      'member_id': 2,
      'member_name': 'Ibu Sari Rahayu',
      'has_paid': 1,
      'won_round': 0,
    });
    await db.insert('arisan_participants', {
      'arisan_id': arisanId,
      'member_id': 3,
      'member_name': 'Ahmad Nurdin',
      'has_paid': 1,
      'won_round': 0,
    });
    await db.insert('arisan_participants', {
      'arisan_id': arisanId,
      'member_id': 4,
      'member_name': 'Wati Susanti',
      'has_paid': 0,
      'won_round': 0,
    });
  }

  Future<List<Arisan>> getAllArisans() async {
    final db = await database;
    final rows = await db.query('arisan', orderBy: 'created_at DESC');
    return rows.map(Arisan.fromMap).toList();
  }

  Future<Arisan?> getArisanById(int id) async {
    final db = await database;
    final rows = await db.query(
      'arisan',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    if (rows.isEmpty) return null;
    return Arisan.fromMap(rows.first);
  }

  Future<int> insertArisan(Arisan arisan) async {
    final db = await database;
    return db.insert('arisan', arisan.toMap()..remove('id'));
  }

  Future<int> updateArisan(Arisan arisan) async {
    final db = await database;
    return db.update(
      'arisan',
      arisan.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[arisan.id],
    );
  }

  Future<int> deleteArisan(int id) async {
    final db = await database;
    await db.delete(
      'arisan_participants',
      where: 'arisan_id = ?',
      whereArgs: <Object?>[id],
    );
    return db.delete('arisan', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<ArisanParticipant>> getParticipants(int arisanId) async {
    final db = await database;
    final rows = await db.query(
      'arisan_participants',
      where: 'arisan_id = ?',
      whereArgs: <Object?>[arisanId],
      orderBy: 'member_name COLLATE NOCASE ASC',
    );
    return rows.map(ArisanParticipant.fromMap).toList();
  }

  Future<int> addParticipant(ArisanParticipant participant) async {
    final db = await database;
    return db.insert('arisan_participants', participant.toMap()..remove('id'));
  }

  Future<int> updateParticipant(ArisanParticipant participant) async {
    final db = await database;
    return db.update(
      'arisan_participants',
      participant.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[participant.id],
    );
  }

  Future<int> removeParticipant(int participantId) async {
    final db = await database;
    return db.delete(
      'arisan_participants',
      where: 'id = ?',
      whereArgs: <Object?>[participantId],
    );
  }

  Future<int> getPaidCount(int arisanId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM arisan_participants WHERE arisan_id = ? AND has_paid = 1',
      <Object?>[arisanId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<void> advanceRound(int arisanId) async {
    final arisan = await getArisanById(arisanId);
    if (arisan == null) return;
    final db = await database;
    await db.update(
      'arisan',
      {'current_round': arisan.currentRound + 1},
      where: 'id = ?',
      whereArgs: <Object?>[arisanId],
    );
  }
}
