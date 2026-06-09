import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'db_helper.dart';

/// Data Access Object لبيانات الحمل في قاعدة البيانات المحلية
class PregnancyDao {
  final DBHelper _dbHelper = DBHelper();

  /// حفظ أو تحديث بيانات الحمل
  Future<int> insertOrReplace(
    String userId,
    Map<String, dynamic> pregnancyData,
  ) async {
    final db = await _dbHelper.database;
    return await db.insert('pregnancy', {
      'user_id': userId,
      'pregnancy_start_date':
          pregnancyData['pregnancyStartDate']?.toString() ?? '',
      'current_week': pregnancyData['currentWeek'] ?? 0,
      'days_in_current_week': pregnancyData['daysInCurrentWeek'] ?? 0,
      'days_remaining': pregnancyData['daysRemaining'] ?? 0,
      'trimester': pregnancyData['trimester'] ?? 1,
      'expected_delivery_date':
          pregnancyData['expectedDeliveryDate']?.toString() ?? '',
      'last_calculated_at':
          pregnancyData['lastCalculatedAt']?.toString() ??
          DateTime.now().toIso8601String(),
      'data_json': jsonEncode(pregnancyData),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// حفظ أو تحديث بيانات الحمل المحلية
  Future<int> savePregnancyTracking(
    String userId,
    Map<String, dynamic> pregnancyData,
  ) {
    return insertOrReplace(userId, pregnancyData);
  }

  /// الحصول على بيانات الحمل للمستخدم
  Future<Map<String, dynamic>?> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'pregnancy',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final data = maps.first;
    try {
      return jsonDecode(data['data_json'] as String? ?? '{}');
    } catch (e) {
      print('خطأ في فك تشفير بيانات الحمل: $e');
      return null;
    }
  }

  /// تحميل بيانات الحمل المحلية للمستخدم
  Future<Map<String, dynamic>?> loadPregnancyTracking(String userId) {
    return getByUserId(userId);
  }

  /// تحديث بيانات الحمل
  Future<int> update(String userId, Map<String, dynamic> pregnancyData) async {
    final db = await _dbHelper.database;
    return await db.update(
      'pregnancy',
      {
        'pregnancy_start_date':
            pregnancyData['pregnancyStartDate']?.toString() ?? '',
        'current_week': pregnancyData['currentWeek'] ?? 0,
        'days_in_current_week': pregnancyData['daysInCurrentWeek'] ?? 0,
        'days_remaining': pregnancyData['daysRemaining'] ?? 0,
        'trimester': pregnancyData['trimester'] ?? 1,
        'expected_delivery_date':
            pregnancyData['expectedDeliveryDate']?.toString() ?? '',
        'last_calculated_at':
            pregnancyData['lastCalculatedAt']?.toString() ??
            DateTime.now().toIso8601String(),
        'data_json': jsonEncode(pregnancyData),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// حذف بيانات الحمل
  Future<int> delete(String userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pregnancy',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// حفظ بيانات الأسبوع (week info)
  Future<int> saveWeekInfo(
    String userId,
    int weekNumber,
    Map<String, dynamic> weekData,
  ) async {
    final db = await _dbHelper.database;
    return await db.insert('pregnancy_weeks', {
      'user_id': userId,
      'week_number': weekNumber,
      'data_json': jsonEncode(weekData),
      'cached_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// الحصول على بيانات الأسبوع المحفوظة
  Future<Map<String, dynamic>?> getWeekInfo(
    String userId,
    int weekNumber,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'pregnancy_weeks',
      where: 'user_id = ? AND week_number = ?',
      whereArgs: [userId, weekNumber],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    try {
      return jsonDecode(maps.first['data_json'] as String);
    } catch (e) {
      print('خطأ في فك تشفير بيانات الأسبوع: $e');
      return null;
    }
  }

  /// حذف بيانات الأسابيع المحفوظة
  Future<int> deleteWeekInfo(String userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pregnancy_weeks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
