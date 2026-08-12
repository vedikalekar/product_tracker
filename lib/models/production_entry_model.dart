class ProductionEntry {
  final int? id;
  final int dailyReportId;
  final String date;
  final String hour;
  final String personInCharge;
  final String model;
  final int target;
  final int achieved;
  final int downtime;
  final String? remarks;

  ProductionEntry({
    this.id,
    required this.dailyReportId,
    required this.date,
    required this.hour,
    required this.personInCharge,
    required this.model,
    required this.target,
    required this.achieved,
    required this.downtime,
    this.remarks,
  });

  double get efficiency => target > 0 ? (achieved / target) * 100 : 0;

  factory ProductionEntry.fromMap(Map<String, dynamic> map) {
    return ProductionEntry(
      id: map['id'] as int?,
      dailyReportId: map['dailyReportId'] as int,
      date: map['date'] as String,
      hour: map['hour'] as String,
      personInCharge: map['personInCharge'] as String,
      model: map['model'] as String,
      target: map['target'] as int,
      achieved: map['achieved'] as int,
      downtime: map['downtime'] as int,
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'dailyReportId': dailyReportId,
      'date': date,
      'hour': hour,
      'personInCharge': personInCharge,
      'model': model,
      'target': target,
      'achieved': achieved,
      'downtime': downtime,
      'remarks': remarks,
    };
  }

  ProductionEntry copyWith({
    int? id,
    int? dailyReportId,
    String? date,
    String? hour,
    String? personInCharge,
    String? model,
    int? target,
    int? achieved,
    int? downtime,
    String? remarks,
  }) {
    return ProductionEntry(
      id: id ?? this.id,
      dailyReportId: dailyReportId ?? this.dailyReportId,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      personInCharge: personInCharge ?? this.personInCharge,
      model: model ?? this.model,
      target: target ?? this.target,
      achieved: achieved ?? this.achieved,
      downtime: downtime ?? this.downtime,
      remarks: remarks ?? this.remarks,
    );
  }
}
