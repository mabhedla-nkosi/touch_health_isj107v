class ConditionsDataModel {
  String? conditionname;
  String? diagnosisdate;
  String? userId;

  ConditionsDataModel({
    this.conditionname,
    this.userId,
    this.diagnosisdate,
  });

  ConditionsDataModel.fromJson(Map<String, dynamic> json)
      : conditionname = json['conditionname'] ?? '',
      userId = json['userId'] ?? '',
      diagnosisdate = json['diagnosisdate'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'conditionname': conditionname,
      'userId': userId,
      'diagnosisdate': diagnosisdate,
    };
  }
}
