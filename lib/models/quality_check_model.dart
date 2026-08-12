class QualityCheck {
  final int? id;
  final int dailyReportId;
  final String date;
  final String parameter;
  final String category;
  final String result;
  final String checkedBy;
  final String? remarks;

  QualityCheck({
    this.id,
    required this.dailyReportId,
    required this.date,
    required this.parameter,
    required this.category,
    required this.result,
    required this.checkedBy,
    this.remarks,
  });

  factory QualityCheck.fromMap(Map<String, dynamic> map) {
    return QualityCheck(
      id: map['id'] as int?,
      dailyReportId: map['dailyReportId'] as int,
      date: map['date'] as String,
      parameter: map['parameter'] as String,
      category: map['category'] as String,
      result: map['result'] as String,
      checkedBy: map['checkedBy'] as String,
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'dailyReportId': dailyReportId,
      'date': date,
      'parameter': parameter,
      'category': category,
      'result': result,
      'checkedBy': checkedBy,
      'remarks': remarks,
    };
  }

  QualityCheck copyWith({
    int? id,
    int? dailyReportId,
    String? date,
    String? parameter,
    String? category,
    String? result,
    String? checkedBy,
    String? remarks,
  }) {
    return QualityCheck(
      id: id ?? this.id,
      dailyReportId: dailyReportId ?? this.dailyReportId,
      date: date ?? this.date,
      parameter: parameter ?? this.parameter,
      category: category ?? this.category,
      result: result ?? this.result,
      checkedBy: checkedBy ?? this.checkedBy,
      remarks: remarks ?? this.remarks,
    );
  }
}
