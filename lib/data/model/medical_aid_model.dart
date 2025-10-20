import 'dart:convert';

class MedicalAidDataModel {
  String? medicalaidname;
  int? medicalaidid;
  String? medicalnumber;
  int? userid;

  MedicalAidDataModel({
    this.medicalaidname,
    this.userid,
    this.medicalnumber,
    this.medicalaidid,
  });

  MedicalAidDataModel.fromJson(Map<String, dynamic> json)
      : medicalaidname = json['medicalaidname'] ?? '',
      userid = json['userid'] ?? 0,
      medicalnumber = json['medicalnumber'] ?? '',
      medicalaidid = json['medicalaidid'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'medicalaidname': medicalaidname,
      'userid': userid,
      'medicalnumber': medicalnumber,
      'medicalaidid': medicalaidid,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
