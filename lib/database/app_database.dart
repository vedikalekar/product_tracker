import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'product_tracker.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
      ),
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reportNumber TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        shift TEXT NOT NULL,
        productionLine TEXT NOT NULL,
        remarks TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE production_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dailyReportId INTEGER NOT NULL,
        date TEXT NOT NULL,
        hour TEXT NOT NULL,
        personInCharge TEXT NOT NULL,
        model TEXT NOT NULL,
        target INTEGER NOT NULL,
        achieved INTEGER NOT NULL,
        downtime INTEGER NOT NULL,
        remarks TEXT,
        FOREIGN KEY (dailyReportId) REFERENCES daily_reports (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE quality_checks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dailyReportId INTEGER NOT NULL,
        date TEXT NOT NULL,
        parameter TEXT NOT NULL,
        category TEXT NOT NULL,
        result TEXT NOT NULL,
        checkedBy TEXT NOT NULL,
        remarks TEXT,
        FOREIGN KEY (dailyReportId) REFERENCES daily_reports (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeCode TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        shift TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE production_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lineCode TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        department TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelCode TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        targetRate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE parameters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paramCode TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        expectedValue TEXT,
        unit TEXT
      )
    ''');
  }
}
