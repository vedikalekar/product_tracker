import 'package:sqflite/sqflite.dart';
import 'package:product_tracker/models/master_data_models.dart';
import 'package:product_tracker/models/daily_report_model.dart';
import 'package:product_tracker/models/production_entry_model.dart';
import 'package:product_tracker/models/quality_check_model.dart';

class SampleDataSeeder {
  static Future<void> seed(Database db) async {
    final reportCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM daily_reports')) ?? 0;
    if (reportCount > 0) return;

    // Seed Employees
    final employees = [
      Employee(employeeCode: 'EMP-001', name: 'Belsari', role: 'Supervisor', shift: 'Morning'),
      Employee(employeeCode: 'EMP-002', name: 'Nikita', role: 'Operator', shift: 'Morning'),
      Employee(employeeCode: 'EMP-003', name: 'Raj', role: 'QC Inspector', shift: 'Morning'),
      Employee(employeeCode: 'EMP-004', name: 'Meena', role: 'Operator', shift: 'Afternoon'),
    ];
    for (var e in employees) {
      await db.insert('employees', e.toMap());
    }

    // Seed Production Lines
    final lines = [
      ProductionLine(lineCode: 'LINE-SMT-01', name: 'SMT Line 1', department: 'SMT', status: 'Active'),
      ProductionLine(lineCode: 'LINE-SMT-02', name: 'SMT Line 2', department: 'SMT', status: 'Active'),
      ProductionLine(lineCode: 'LINE-PCB-01', name: 'PCB Assembly', department: 'Assembly', status: 'Active'),
    ];
    for (var l in lines) {
      await db.insert('production_lines', l.toMap());
    }

    // Seed Models
    final models = [
      ModelItem(modelCode: 'MDL-SMT-860-1', name: 'Model 860-1', targetRate: 100),
      ModelItem(modelCode: 'MDL-PCB-4133-X', name: 'Model 4133-X', targetRate: 50),
      ModelItem(modelCode: 'MDL-SMT-720-A', name: 'Model 720-A', targetRate: 120),
      ModelItem(modelCode: 'MDL-PCB-2200-B', name: 'Model 2200-B', targetRate: 80),
    ];
    for (var m in models) {
      await db.insert('models', m.toMap());
    }

    // Seed Quality Parameters
    final params = [
      QualityParameter(paramCode: 'QP-001', name: 'Solder Paste Height', category: 'Dimensional', expectedValue: '120', unit: 'um'),
      QualityParameter(paramCode: 'QP-002', name: 'Component Placement', category: 'Visual', expectedValue: 'Accurate', unit: null),
      QualityParameter(paramCode: 'QP-003', name: 'Reflow Profile', category: 'Temperature', expectedValue: 'Profile 1', unit: null),
      QualityParameter(paramCode: 'QP-004', name: 'Visual Inspection', category: 'Visual', expectedValue: 'Pass', unit: null),
      QualityParameter(paramCode: 'QP-005', name: 'ICT Test', category: 'Electrical', expectedValue: 'Pass', unit: null),
      QualityParameter(paramCode: 'QP-006', name: 'Functional Test', category: 'Electrical', expectedValue: 'Pass', unit: null),
    ];
    for (var p in params) {
      await db.insert('parameters', p.toMap());
    }

    // Seed Daily Reports & Entries & Checks
    final report1 = DailyReport(reportNumber: 'RPT-2026-001', date: '2026-08-12', shift: 'Morning', productionLine: 'SMT Line 1');
    final r1Id = await db.insert('daily_reports', report1.toMap());

    final entries1 = [
      ProductionEntry(dailyReportId: r1Id, date: '2026-08-12', hour: '08:00-09:00', personInCharge: 'Nikita', model: 'Model 860-1', target: 100, achieved: 95, downtime: 5),
      ProductionEntry(dailyReportId: r1Id, date: '2026-08-12', hour: '09:00-10:00', personInCharge: 'Nikita', model: 'Model 860-1', target: 100, achieved: 100, downtime: 0),
      ProductionEntry(dailyReportId: r1Id, date: '2026-08-12', hour: '10:00-11:00', personInCharge: 'Nikita', model: 'Model 860-1', target: 100, achieved: 90, downtime: 10),
    ];
    for (var e in entries1) {
      await db.insert('production_entries', e.toMap());
    }

    final checks1 = [
      QualityCheck(dailyReportId: r1Id, date: '2026-08-12', parameter: 'Solder Paste Height', category: 'Dimensional', result: 'Pass', checkedBy: 'Raj'),
      QualityCheck(dailyReportId: r1Id, date: '2026-08-12', parameter: 'Component Placement', category: 'Visual', result: 'Pass', checkedBy: 'Raj'),
    ];
    for (var c in checks1) {
      await db.insert('quality_checks', c.toMap());
    }

    final report2 = DailyReport(reportNumber: 'RPT-2026-002', date: '2026-08-12', shift: 'Afternoon', productionLine: 'PCB Assembly');
    final r2Id = await db.insert('daily_reports', report2.toMap());

    final entries2 = [
      ProductionEntry(dailyReportId: r2Id, date: '2026-08-12', hour: '14:00-15:00', personInCharge: 'Meena', model: 'Model 4133-X', target: 50, achieved: 48, downtime: 0),
      ProductionEntry(dailyReportId: r2Id, date: '2026-08-12', hour: '15:00-16:00', personInCharge: 'Meena', model: 'Model 4133-X', target: 50, achieved: 50, downtime: 0),
      ProductionEntry(dailyReportId: r2Id, date: '2026-08-12', hour: '16:00-17:00', personInCharge: 'Meena', model: 'Model 4133-X', target: 50, achieved: 45, downtime: 15),
      ProductionEntry(dailyReportId: r2Id, date: '2026-08-12', hour: '17:00-18:00', personInCharge: 'Meena', model: 'Model 4133-X', target: 50, achieved: 50, downtime: 0),
    ];
    for (var e in entries2) {
      await db.insert('production_entries', e.toMap());
    }

    final checks2 = [
      QualityCheck(dailyReportId: r2Id, date: '2026-08-12', parameter: 'Visual Inspection', category: 'Visual', result: 'Pass', checkedBy: 'Belsari'),
      QualityCheck(dailyReportId: r2Id, date: '2026-08-12', parameter: 'Functional Test', category: 'Electrical', result: 'Fail', checkedBy: 'Belsari', remarks: 'Failed power up'),
    ];
    for (var c in checks2) {
      await db.insert('quality_checks', c.toMap());
    }
  }
}
