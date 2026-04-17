import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'dzikir.dart';

class DzikirLocalDatabase {
  DzikirLocalDatabase._();

  static final DzikirLocalDatabase instance = DzikirLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = path.join(await getDatabasesPath(), 'ventri_dzikir.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE dzikir (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target_count INTEGER NOT NULL,
            current_count INTEGER NOT NULL DEFAULT 0,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Dzikir>> getAllDzikir() async {
    final db = await database;
    final rows = await db.query('dzikir', orderBy: 'created_at DESC');
    return rows.map(Dzikir.fromMap).toList();
  }

  Future<Dzikir?> getActiveDzikir() async {
    final db = await database;
    final rows = await db.query(
      'dzikir',
      where: 'current_count < target_count',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Dzikir.fromMap(rows.first);
  }

  Future<Dzikir?> getLastDzikir() async {
    final db = await database;
    final rows = await db.query('dzikir', orderBy: 'created_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return Dzikir.fromMap(rows.first);
  }

  Future<int> insertDzikir(Dzikir dzikir) async {
    final db = await database;
    return db.insert('dzikir', dzikir.toMap()..remove('id'));
  }

  Future<int> updateDzikir(Dzikir dzikir) async {
    final db = await database;
    return db.update(
      'dzikir',
      dzikir.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[dzikir.id],
    );
  }

  Future<int> deleteDzikir(int id) async {
    final db = await database;
    return db.delete('dzikir', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<int> incrementCount(int id) async {
    final db = await database;
    return db.rawUpdate(
      'UPDATE dzikir SET current_count = current_count + 1 WHERE id = ?',
      <Object?>[id],
    );
  }
}
