import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/cycle_model.dart';
 
class CycleDao {
  final DBHelper _dbHelper = DBHelper();
 
  // Insérer ou remplacer le cycle
  Future<int> insertOrReplace(CycleModel cycle) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'cycles',
      cycle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
 
  // Récupérer le cycle de l'utilisateur
  Future<CycleModel?> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cycles',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CycleModel.fromMap(maps.first);
  }
 
  // Mettre à jour
  Future<int> update(CycleModel cycle) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cycles',
      cycle.toMap(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }
 
  // Supprimer
  Future<int> delete(String userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'cycles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}