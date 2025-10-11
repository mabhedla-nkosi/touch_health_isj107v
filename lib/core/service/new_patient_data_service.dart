import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientData {
  int? userid;
  //DateTime? date;
  String? name; 
  String? surname;
  String? phone; 
  String? email;
  String? id_passportnumber; 
  String? gender; 
  String? dob;
  String? nationality;
  List<Appointment>? appointments;

  PatientData({
    //this.date,
    this.userid,  
    this.name, 
    this.surname, 
    this.phone, 
    this.email, 
    this.id_passportnumber, 
    this.gender,
    this.dob,
    this.nationality,
    this.appointments,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      userid: json['userid'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userid": userid,
      "name": name,
      "surname": surname,
      "phone": phone,
      "email": email,
      "id_passportnumber": id_passportnumber,
      "gender": gender,
      "dob": dob,
      "nationality": nationality,
      "appointments": appointments?.map((ap) => ap.toJson()).toList() ?? [],
    };
  }

  @override
  String toString() {
    return 'User(userId: $userid, name: $name, surname: $surname, email: $email, gender: $gender, dob: $dob)';
  }
}

class Appointment {
  int? app_id;
  int? practitionerid;
  String? status;
  String? notes;

  Appointment({
    this.app_id,
    this.practitionerid,
    this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      app_id: json['app_id'],
      practitionerid: json['practitionerid'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "app_id": app_id,
    "practitionerid": practitionerid,
    "status": status,
    "notes": notes,
  };
}
}


class PatientDataService {
  //final String baseUrl = "http://10.0.2.2:5000";
  final String baseUrl = "https://postgres-api-hrd8.onrender.com";
    // for Android emulator
  // use http://localhost:5000 if on iOS simulator or web

  Future<List<PatientData>> getPatientData() async {
    final response = await http.get(Uri.parse("$baseUrl/patientData"));
    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final patients = decoded
          .map((e) => PatientData.fromJson(e['patient']))
          .toList();

        return patients;
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<List<PatientData>> getPatientDataByEmail(String emailAddress) async {
    final encodedEmail = Uri.encodeComponent(emailAddress); 
    final response = await http.get(Uri.parse("$baseUrl/patientData/email/$encodedEmail"));
    if (response.statusCode == 200) {

      // final decoded = jsonDecode(response.body) as List<dynamic>;
      // final patients = decoded
      //     .map((e) => PatientData.fromJson(e))
      //     .toList();
      final decoded = jsonDecode(response.body);      
      
      final patient = PatientData.fromJson(decoded);
      final patients = [patient].toList();

        return patients;
    } else {
      throw Exception("Failed to load users");
    }
  }

  // Future<PatientData> addUser(String name, int age) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/users"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({"name": name, "age": age}),
  //   );
  //   if (response.statusCode == 200) {
  //     return PatientData.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception("Failed to add user");
  //   }
  // }
}
