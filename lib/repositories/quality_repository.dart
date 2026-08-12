import 'package:sqflite/sqflite.dart';
import 'package:product_tracker/database/app_database.dart';
import 'package:product_tracker/models/quality_check_model.dart';

class QualityRepository {
  /// Gets quality checks, optionally filtered by daily report id
  Future<List<QualityCheck>> getQualityChecks({int? dailyReportId}) async {
    final db = await AppDatabase.database;
    List<Map<String, dynamic>> maps;
    if (dailyReportId != null) {
      maps = await db.query('quality_checks', where: 'dailyReportId = ?', whereArgs: [dailyReportId]);
    } else {
      maps = await db.query('quality_checks');
    }
    return maps.map((e) => QualityCheck.fromMap(e)).toList();
  }

  /// Adds a new quality check
  Future<QualityCheck> addQualityCheck(QualityCheck check) async {
    final db = await AppDatabase.database;
    final id = await db.insert('quality_checks', check.toMap());
    return check.copyWith(id: id);
  }

  /// Updates an existing quality check
  Future<void> updateQualityCheck(QualityCheck check) async {
    final db = await AppDatabase.database;
    await db.update('quality_checks', check.toMap(), where: 'id = ?', whereArgs: [check.id]);
  }

  /// Deletes a quality check by id
  Future<void> deleteQualityCheck(int id) async {
    final db = await AppDatabase.database;
    await db.delete('quality_checks', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets aggregated quality metrics
  Future<Map<String, dynamic>> getQualityMetrics() async {
    final db = await AppDatabase.database;
    final totalChecks = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quality_checks')) ?? 0;
    final failCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quality_checks WHERE result = ?', ['Fail'])) ?? 0;
    
    double passRate = 0;
    if (totalChecks > 0) {
      final passCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quality_checks WHERE result = ?', ['Pass'])) ?? 0;
      passRate = (passCount / totalChecks) * 100;
    }

    final catQuery = await db.rawQuery('SELECT category, COUNT(*) as count FROM quality_checks GROUP BY category');
    Map<String, int> categories = {};
    for (var row in catQuery) {
      categories[row['category'] as String] = (row['count'] as num).toInt();
    }

    return {
      'totalChecks': totalChecks,
      'passRate': passRate,
      'failCount': failCount,
      'categories': categories,
    };
  }
}
