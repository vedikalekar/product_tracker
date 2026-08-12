class DailyReport {
  final int? id;
  final String reportNumber;
  final String date;
  final String shift;
  final String productionLine;
  final String? remarks;

  DailyReport({
    this.id,
    required this.reportNumber,
    required this.date,
    required this.shift,
    required this.productionLine,
    this.remarks,
  });

  factory DailyReport.fromMap(Map<String, dynamic> map) {
    return DailyReport(
      id: map['id'] as int?,
      reportNumber: map['reportNumber'] as String,
      date: map['date'] as String,
      shift: map['shift'] as String,
      productionLine: map['productionLine'] as String,
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportNumber': reportNumber,
      'date': date,
      'shift': shift,
      'productionLine': productionLine,
      'remarks': remarks,
    };
  }

  DailyReport copyWith({
    int? id,
    String? reportNumber,
    String? date,
    String? shift,
    String? productionLine,
    String? remarks,
  }) {
    return DailyReport(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      productionLine: productionLine ?? this.productionLine,
      remarks: remarks ?? this.remarks,
    );
  }
}
