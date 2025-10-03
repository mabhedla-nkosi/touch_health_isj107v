class LabScreeningDataModel {
  String? status;
  String? date;
  String? userId;
  String? testcost;
  String? practitioner;

  LabScreeningDataModel({
    this.status,
    this.userId,
    this.date,
    this.testcost,
    this.practitioner,
  });

  LabScreeningDataModel.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? '',
      userId = json['userId'] ?? '',
      testcost = json['testcost'] ?? '',
      practitioner = json['practitioner'] ?? '',
      date = json['date'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'userId': userId,
      'practitioner': practitioner,
      'testcost': testcost,
      'date': date,
    };
  }
}
