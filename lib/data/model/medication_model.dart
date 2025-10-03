class MedicationDataModel {
  String? dosage;
  String? userId;
  String? medicationname;

  MedicationDataModel({
    this.dosage,
    this.userId,
    this.medicationname,
  });

  MedicationDataModel.fromJson(Map<String, dynamic> json)
      : dosage = json['dosage'] ?? '',
      userId = json['userId'] ?? '',
      medicationname = json['medicationname'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'dosage': dosage,
      'userId': userId,
      'medicationname': medicationname,
    };
  }
}
