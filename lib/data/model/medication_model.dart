class Medication {
  int? medicationid;
  int? userid;
  String? medicationname;
  String? dosage;
  String? frequency;

  Medication({
    this.medicationid,
    this.userid,
    this.medicationname,
    this.dosage,
    this.frequency,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      medicationid: json['medicationid'],
      userid: json['userid'],
      medicationname: json['medicationname'],
      dosage: json['dosage'],
      frequency: json['frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "medicationid": medicationid,
      "userid": userid,
      "medicationname": medicationname,
      "dosage": dosage,
      "frequency": frequency,
    };
  }
}