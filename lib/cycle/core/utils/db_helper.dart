import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zyra_cycle.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Table pour stocker les paramètres de l'onboarding
    await db.execute('''
      CREATE TABLE user_settings (
        id TEXT PRIMARY KEY,
        last_period_start TEXT NOT NULL,
        cycle_duration INTEGER NOT NULL,
        period_duration INTEGER NOT NULL,
        regularity TEXT NOT NULL,
        main_goal TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Table pour stocker les cycles
    await db.execute('''
      CREATE TABLE cycles (
        id TEXT PRIMARY KEY,
        start_date TEXT NOT NULL,
        end_date TEXT,
        predicted_ovulation TEXT NOT NULL,
        predicted_fertility_start TEXT NOT NULL,
        predicted_fertility_end TEXT NOT NULL,
        cycle_duration INTEGER NOT NULL,
        period_duration INTEGER NOT NULL,
        regularity TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cycles ADD COLUMN cycle_duration INTEGER NOT NULL DEFAULT 28');
      await db.execute('ALTER TABLE cycles ADD COLUMN period_duration INTEGER NOT NULL DEFAULT 5');
      await db.execute('ALTER TABLE cycles ADD COLUMN regularity TEXT NOT NULL DEFAULT "Régulier"');
    }
  }
}