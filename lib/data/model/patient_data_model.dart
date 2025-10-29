import 'dart:convert';

import 'package:touchhealth/data/model/conditions_model.dart';
import 'package:touchhealth/data/model/patient_appointment_model.dart';
import 'package:touchhealth/data/model/patient_vitals_model.dart';
import 'package:touchhealth/data/model/medication_model.dart';

class PatientData {
  int? userid;
  //DateTime? date;
  String? medicalNumber;
  String? name; 
  String? surname;
  String? phone; 
  String? email;
  String? id_passportnumber; 
  String? gender; 
  String? dob;
  String? nationality;
  List<Appointment>? appointments;
  List<Vitals>? vitals;
  List<Medication>? medication;
  List<Condition>? conditions;

  PatientData({
    //this.date,
    this.userid,  
    this.medicalNumber,
    this.name, 
    this.surname, 
    this.phone, 
    this.email, 
    this.id_passportnumber, 
    this.gender,
    this.dob,
    this.nationality,
    this.appointments,
    this.vitals,
    this.medication,
    this.conditions
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      userid: json['userid'],
      medicalNumber : json['medicalNumber'],
      name: json['name'],
      surname: json['surname'],
      phone: json['phone'],
      email: json['email'],
      id_passportnumber: json['id_passportnumber'],
      gender: json['gender'],
      dob: json['dob'],
      nationality: json['nationality'], 
      //date: json['date'] != null ? DateTime.parse(json['date']) : null,
      appointments: (json['appointments'] as List<dynamic>)
          .map((ap) => Appointment.fromJson(ap))
          .toList(),
      vitals: (json['vitals'] as List<dynamic>)
          .map((ap) => Vitals.fromJson(ap))
          .toList(),
      medication: (json['medication'] as List<dynamic>)
          .map((ap) => Medication.fromJson(ap))
          .toList(),
      conditions: (json['conditions'] as List<dynamic>)
          .map((ap) => Condition.fromJson(ap))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userid": userid,
      "medicalNumber":medicalNumber,
      "name": name,
      "surname": surname,
      "phone": phone,
      "email": email,
      "id_passportnumber": id_passportnumber,
      "gender": gender,
      "dob": dob,
      "nationality": nationality,
      "appointments": appointments?.map((ap) => ap.toJson()).toList() ?? [],
      "vitals": vitals?.map((ap) => ap.toJson()).toList() ?? [],
      "medication": medication?.map((ap) => ap.toJson()).toList() ?? [],
      "conditions": conditions?.map((ap) => ap.toJson()).toList() ?? [],
    };
  }

  @override
  // String toString() {
  //   return 'User(userId: $userid, name: $name, surname: $surname, email: $email, gender: $gender, dob: $dob)';
  // }
  String toString() => jsonEncode(toJson());
}