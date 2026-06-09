import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final path = join(dbPath, 'zyra_pregnancy.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pregnancy (
        user_id TEXT PRIMARY KEY,
        pregnancy_start_date TEXT,
        current_week INTEGER NOT NULL DEFAULT 0,
        days_in_current_week INTEGER NOT NULL DEFAULT 0,
        days_remaining INTEGER NOT NULL DEFAULT 0,
        trimester INTEGER NOT NULL DEFAULT 1,
        expected_delivery_date TEXT,
        last_calculated_at TEXT NOT NULL,
        data_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pregnancy_weeks (
        user_id TEXT NOT NULL,
        week_number INTEGER NOT NULL,
        data_json TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        PRIMARY KEY (user_id, week_number)
      )
    ''');
  }
}
