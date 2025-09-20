class MedicalAidDataModel {
  String? medicalaidname;
  String? medicaliadid;
  String? medicalaidnumber;
  String? userId;

  MedicalAidDataModel({
    this.medicalaidname,
    this.userId,
    this.medicalaidnumber,
    this.medicaliadid,
  });

  MedicalAidDataModel.fromJson(Map<String, dynamic> json)
      : medicalaidname = json['medicalaidname'] ?? '',
      userId = json['userId'] ?? '',
      medicalaidnumber = json['medicalaidnumber'] ?? '',
      medicaliadid = json['medicaliadid'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'medicalaidname': medicalaidname,
      'userId': userId,
      'medicalaidnumber': medicalaidnumber,
      'medicaliadid': medicaliadid,
    };
  }
}
