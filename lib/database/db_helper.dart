import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
 
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();
 
  static Database? _database;
 
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }
 
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zyra.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  // 📥 update avatar
Future<int> updateAvatar(String uid, String path) async {
  final db = await database;
  return await db.update(
    'users',
    {'avatar_path': path},
    where: 'firebase_uid = ?',
    whereArgs: [uid],
  );
}

// 📤 get avatar
Future<String?> getAvatar(String uid) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'firebase_uid = ?',
    whereArgs: [uid],
  );

  if (result.isNotEmpty) {
    return result.first['avatar_path'] as String?;
  }
  return null;
}
 
  Future<void> _onCreate(Database db, int version) async {
    // Table utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        nom           TEXT NOT NULL,
        prenom        TEXT NOT NULL,
        email         TEXT NOT NULL UNIQUE,
        avatar_path   TEXT,
        firebase_uid  TEXT UNIQUE,
        created_at    TEXT NOT NULL
      )
    ''');
 
    // Table cycles
    await db.execute('''
      CREATE TABLE cycles (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id         TEXT NOT NULL,
        duree_cycle     INTEGER NOT NULL DEFAULT 28,
        duree_regles    INTEGER NOT NULL DEFAULT 5,
        derniere_regles TEXT NOT NULL,
        mode_grossesse  INTEGER NOT NULL DEFAULT 0,
        updated_at      TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(firebase_uid)
      )
    ''');
  }
}