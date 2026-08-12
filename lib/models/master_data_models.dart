class Employee {
  final int? id;
  final String employeeCode;
  final String name;
  final String role;
  final String shift;

  Employee({
    this.id,
    required this.employeeCode,
    required this.name,
    required this.role,
    required this.shift,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      employeeCode: map['employeeCode'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      shift: map['shift'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'employeeCode': employeeCode,
      'name': name,
      'role': role,
      'shift': shift,
    };
  }

  Employee copyWith({
    int? id,
    String? employeeCode,
    String? name,
    String? role,
    String? shift,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      role: role ?? this.role,
      shift: shift ?? this.shift,
    );
  }
}

class ProductionLine {
  final int? id;
  final String lineCode;
  final String name;
  final String department;
  final String status;

  ProductionLine({
    this.id,
    required this.lineCode,
    required this.name,
    required this.department,
    required this.status,
  });

  factory ProductionLine.fromMap(Map<String, dynamic> map) {
    return ProductionLine(
      id: map['id'] as int?,
      lineCode: map['lineCode'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'lineCode': lineCode,
      'name': name,
      'department': department,
      'status': status,
    };
  }

  ProductionLine copyWith({
    int? id,
    String? lineCode,
    String? name,
    String? department,
    String? status,
  }) {
    return ProductionLine(
      id: id ?? this.id,
      lineCode: lineCode ?? this.lineCode,
      name: name ?? this.name,
      department: department ?? this.department,
      status: status ?? this.status,
    );
  }
}

class ModelItem {
  final int? id;
  final String modelCode;
  final String name;
  final int targetRate;

  ModelItem({
    this.id,
    required this.modelCode,
    required this.name,
    required this.targetRate,
  });

  factory ModelItem.fromMap(Map<String, dynamic> map) {
    return ModelItem(
      id: map['id'] as int?,
      modelCode: map['modelCode'] as String,
      name: map['name'] as String,
      targetRate: map['targetRate'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'modelCode': modelCode,
      'name': name,
      'targetRate': targetRate,
    };
  }

  ModelItem copyWith({
    int? id,
    String? modelCode,
    String? name,
    int? targetRate,
  }) {
    return ModelItem(
      id: id ?? this.id,
      modelCode: modelCode ?? this.modelCode,
      name: name ?? this.name,
      targetRate: targetRate ?? this.targetRate,
    );
  }
}

class QualityParameter {
  final int? id;
  final String paramCode;
  final String name;
  final String category;
  final String? expectedValue;
  final String? unit;

  QualityParameter({
    this.id,
    required this.paramCode,
    required this.name,
    required this.category,
    this.expectedValue,
    this.unit,
  });

  factory QualityParameter.fromMap(Map<String, dynamic> map) {
    return QualityParameter(
      id: map['id'] as int?,
      paramCode: map['paramCode'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      expectedValue: map['expectedValue'] as String?,
      unit: map['unit'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'paramCode': paramCode,
      'name': name,
      'category': category,
      'expectedValue': expectedValue,
      'unit': unit,
    };
  }

  QualityParameter copyWith({
    int? id,
    String? paramCode,
    String? name,
    String? category,
    String? expectedValue,
    String? unit,
  }) {
    return QualityParameter(
      id: id ?? this.id,
      paramCode: paramCode ?? this.paramCode,
      name: name ?? this.name,
      category: category ?? this.category,
      expectedValue: expectedValue ?? this.expectedValue,
      unit: unit ?? this.unit,
    );
  }
}
