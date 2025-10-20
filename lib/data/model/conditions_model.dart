class Condition {
  int? conditionid;
  String? conditionname;
  String? diagnosisdate;
  int? userid;

  Condition({
    this.conditionid,
    this.conditionname,
    this.diagnosisdate,
    this.userid
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      conditionid: json['conditionid'],
      conditionname: json['conditionname'],
      diagnosisdate: json['diagnosisdate'],
      userid: json['userid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionid': conditionid,
      'conditionname': conditionname,
      'diagnosisdate': diagnosisdate,
      'userid': userid
    };
  }
}