import 'package:product_tracker/database/app_database.dart';
import 'package:product_tracker/models/master_data_models.dart';

class MasterDataRepository {
  /// Gets all employees
  Future<List<Employee>> getEmployees() async {
    final db = await AppDatabase.database;
    final maps = await db.query('employees');
    return maps.map((e) => Employee.fromMap(e)).toList();
  }

  /// Adds a new employee
  Future<void> addEmployee(Employee e) async {
    final db = await AppDatabase.database;
    await db.insert('employees', e.toMap());
  }

  /// Updates an existing employee
  Future<void> updateEmployee(Employee e) async {
    final db = await AppDatabase.database;
    await db.update('employees', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  /// Deletes an employee by id
  Future<void> deleteEmployee(int id) async {
    final db = await AppDatabase.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets all production lines
  Future<List<ProductionLine>> getProductionLines() async {
    final db = await AppDatabase.database;
    final maps = await db.query('production_lines');
    return maps.map((e) => ProductionLine.fromMap(e)).toList();
  }

  /// Adds a new production line
  Future<void> addProductionLine(ProductionLine line) async {
    final db = await AppDatabase.database;
    await db.insert('production_lines', line.toMap());
  }

  /// Updates an existing production line
  Future<void> updateProductionLine(ProductionLine line) async {
    final db = await AppDatabase.database;
    await db.update('production_lines', line.toMap(), where: 'id = ?', whereArgs: [line.id]);
  }

  /// Deletes a production line by id
  Future<void> deleteProductionLine(int id) async {
    final db = await AppDatabase.database;
    await db.delete('production_lines', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets all models
  Future<List<ModelItem>> getModels() async {
    final db = await AppDatabase.database;
    final maps = await db.query('models');
    return maps.map((e) => ModelItem.fromMap(e)).toList();
  }

  /// Adds a new model
  Future<void> addModel(ModelItem model) async {
    final db = await AppDatabase.database;
    await db.insert('models', model.toMap());
  }

  /// Updates an existing model
  Future<void> updateModel(ModelItem model) async {
    final db = await AppDatabase.database;
    await db.update('models', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  /// Deletes a model by id
  Future<void> deleteModel(int id) async {
    final db = await AppDatabase.database;
    await db.delete('models', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets all quality parameters
  Future<List<QualityParameter>> getParameters() async {
    final db = await AppDatabase.database;
    final maps = await db.query('parameters');
    return maps.map((e) => QualityParameter.fromMap(e)).toList();
  }

  /// Adds a new quality parameter
  Future<void> addParameter(QualityParameter param) async {
    final db = await AppDatabase.database;
    await db.insert('parameters', param.toMap());
  }

  /// Updates an existing quality parameter
  Future<void> updateParameter(QualityParameter param) async {
    final db = await AppDatabase.database;
    await db.update('parameters', param.toMap(), where: 'id = ?', whereArgs: [param.id]);
  }

  /// Deletes a quality parameter by id
  Future<void> deleteParameter(int id) async {
    final db = await AppDatabase.database;
    await db.delete('parameters', where: 'id = ?', whereArgs: [id]);
  }

  /// Gets list of employee names for dropdowns
  Future<List<String>> getEmployeeNames() async {
    final db = await AppDatabase.database;
    final maps = await db.query('employees', columns: ['name']);
    return maps.map((e) => e['name'] as String).toList();
  }

  /// Gets list of production line names for dropdowns
  Future<List<String>> getProductionLineNames() async {
    final db = await AppDatabase.database;
    final maps = await db.query('production_lines', columns: ['name']);
    return maps.map((e) => e['name'] as String).toList();
  }

  /// Gets list of model names for dropdowns
  Future<List<String>> getModelNames() async {
    final db = await AppDatabase.database;
    final maps = await db.query('models', columns: ['name']);
    return maps.map((e) => e['name'] as String).toList();
  }

  /// Gets list of parameter names for dropdowns
  Future<List<String>> getParameterNames() async {
    final db = await AppDatabase.database;
    final maps = await db.query('parameters', columns: ['name']);
    return maps.map((e) => e['name'] as String).toList();
  }
}
