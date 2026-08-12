import 'package:sqflite/sqflite.dart';
import 'package:product_tracker/database/app_database.dart';
import 'package:product_tracker/models/daily_report_model.dart';
import 'package:product_tracker/models/production_entry_model.dart';

class ProductionRepository {
  /// Gets all daily reports ordered by date descending
  Future<List<DailyReport>> getDailyReports() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('daily_reports', orderBy: 'date DESC');
    return maps.map((e) => DailyReport.fromMap(e)).toList();
  }

  /// Gets a specific daily report by id
  Future<DailyReport?> getDailyReportById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('daily_reports', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return DailyReport.fromMap(maps.first);
    }
    return null;
  }

  /// Creates a new daily report and returns the instance with its assigned id
  Future<DailyReport> createDailyReport(DailyReport report) async {
    final db = await AppDatabase.database;
    final id = await db.insert('daily_reports', report.toMap());
    return report.copyWith(id: id);
  }

  /// Updates an existing daily report
  Future<void> updateDailyReport(DailyReport report) async {
    final db = await AppDatabase.database;
    await db.update('daily_reports', report.toMap(), where: 'id = ?', whereArgs: [report.id]);
  }

  /// Deletes a daily report by id
  Future<void> deleteDailyReport(int id) async {
    final db = await AppDatabase.database;
    await db.delete('daily_reports', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets production entries for a specific daily report
  Future<List<ProductionEntry>> getProductionEntries(int dailyReportId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('production_entries', where: 'dailyReportId = ?', whereArgs: [dailyReportId], orderBy: 'hour ASC');
    return maps.map((e) => ProductionEntry.fromMap(e)).toList();
  }

  /// Adds a new production entry and returns the instance with its assigned id
  Future<ProductionEntry> addProductionEntry(ProductionEntry entry) async {
    final db = await AppDatabase.database;
    final id = await db.insert('production_entries', entry.toMap());
    return entry.copyWith(id: id);
  }

  /// Updates an existing production entry
  Future<void> updateProductionEntry(ProductionEntry entry) async {
    final db = await AppDatabase.database;
    await db.update('production_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  /// Deletes a production entry by id
  Future<void> deleteProductionEntry(int id) async {
    final db = await AppDatabase.database;
    await db.delete('production_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets aggregated metrics for the dashboard
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final db = await AppDatabase.database;
    final reportCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM daily_reports')) ?? 0;
    
    final entryStats = await db.rawQuery('SELECT SUM(achieved) as totalProduction, SUM(target) as totalTarget, SUM(downtime) as totalDowntime FROM production_entries');
    int totalProduction = 0;
    int totalTarget = 0;
    int totalDowntime = 0;
    if (entryStats.isNotEmpty) {
      totalProduction = (entryStats.first['totalProduction'] as num?)?.toInt() ?? 0;
      totalTarget = (entryStats.first['totalTarget'] as num?)?.toInt() ?? 0;
      totalDowntime = (entryStats.first['totalDowntime'] as num?)?.toInt() ?? 0;
    }
    
    double avgEfficiency = 0;
    if (totalTarget > 0) {
      avgEfficiency = (totalProduction / totalTarget) * 100;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final todayStats = await db.rawQuery('SELECT SUM(achieved) as todayProduction FROM production_entries WHERE date = ?', [today]);
    int todayProduction = 0;
    if (todayStats.isNotEmpty) {
      todayProduction = (todayStats.first['todayProduction'] as num?)?.toInt() ?? 0;
    }

    return {
      'totalReports': reportCount,
      'totalProduction': totalProduction,
      'avgEfficiency': avgEfficiency,
      'totalDowntime': totalDowntime,
      'todayProduction': todayProduction,
    };
  }
}
