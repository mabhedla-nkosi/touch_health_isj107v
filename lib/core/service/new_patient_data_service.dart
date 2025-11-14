import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchhealth/data/model/medical_aid_model.dart';
import 'package:touchhealth/data/model/user_address_model.dart';
import 'package:touchhealth/data/model/patient_data_model.dart';
import 'package:touchhealth/data/model/user_data_model.dart';

class PatientDataService {
  final String baseUrl = "http://10.0.2.2:5000";
  //final String baseUrl = "https://postgres-api-hrd8.onrender.com";
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

  //byID
  Future<List<PatientData>> getPatientDataById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/patientData/$id"));
    if (response.statusCode == 200) {

      // final decoded = jsonDecode(response.body) as List<dynamic>;
      // final patients = decoded
      //     .map((e) => PatientData.fromJson(e['patient']))
      //     .toList();

      //   return patients;

      final decoded = jsonDecode(response.body); 
      
      final patient = PatientData.fromJson(decoded);
      final patients = [patient].toList();

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
      //print(patients);

        return patients;
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<List<MedicalAidDataModel>> getMedicalAidByUserId(int medicalAidId) async {
    final response = await http.get(Uri.parse("$baseUrl/medicalaid/$medicalAidId"));
    if (response.statusCode == 200) {
      

      final decoded = jsonDecode(response.body); 
      
      final medicalAidData = MedicalAidDataModel.fromJson(decoded);
      final returnMedicalAidData = [medicalAidData].toList();

        return returnMedicalAidData;
    } else {
      throw Exception("Failed to load users");
    }
  }

  //getUserAddressByUserId
  Future<List<UserAddressDataModel>> getUserAddressByUserId(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/useraddress/$userId"));
    if (response.statusCode == 200) {
    
      final decoded = jsonDecode(response.body); 
      
      final userAddressData = UserAddressDataModel.fromJson(decoded);
      final returnUserAddressData = [userAddressData].toList();

        return returnUserAddressData;
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<List<UserDataModel>> getProfileDataByUserId(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId"));
    if (response.statusCode == 200) {
      

      final decoded = jsonDecode(response.body);
      
      final userData = UserDataModel.fromJson(decoded['user_json']);
      final returnUserData = [userData].toList();

        return returnUserData;
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

  Future<bool> updateUserName({
      required int userId,
      required String newName,
    }) async {
      final url = Uri.parse("$baseUrl/updateUserName");

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userid': userId,
            'name': newName,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['success'] == true;
        } else {
          return false;
        }
      } catch (e) {
        print("Error updating user name: $e");
        return false;
      }
    }

  Map<String, dynamic>? _cachedUser;
  Future<bool> logIn({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _cachedUser = data['user']; // optional: keep in memory
        return true;
      }
    }
    return false;
  }

  // Get cached user
  Map<String, dynamic> getCachedUser() {
    if (_cachedUser != null) {
      return _cachedUser!;
    } else {
      throw Exception("No cached user found. Please log in first.");
    }
  }


  Future<void> updateUserAccount(UserDataModel user) async {
  final int parsedUserId = int.tryParse(user.userId ?? '') ?? 0;

  if (parsedUserId == 0) {
    throw Exception("Invalid userId for update");
  }

  final url = Uri.parse("$baseUrl/updateUserAccount/$parsedUserId");

  final body = jsonEncode({
    'name': user.name,
    'surname': user.surname,
    'phone': user.phone,
    'email': user.email,
    'password': user.password,
    'id_passportnumber': user.id_passportnumber,
    'gender': user.gender,
    'dob': user.dob,
    'nationality': user.nationality,
  });

  final headers = {'Content-Type': 'application/json'};

  final response = await http.put(url, headers: headers, body: body);

  if (response.statusCode != 200) {
    throw Exception("Failed to update account: ${response.body}");
  }
}


  Future<void> updateMedicalAid({
    required String medicalAidName,
    required String medicalAidNumber,
    required int userId,
    required int medicalAidId,
  }) async {
    final url = Uri.parse("$baseUrl/medicalaid/update");

    final body = jsonEncode({
      'medicalaidname': medicalAidName,
      'medicalnumber': medicalAidNumber,
      'userid': userId,
      'medicalaidid': medicalAidId,
    });

    final headers = {'Content-Type': 'application/json'};

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception("Failed to update medical aid details: ${response.body}");
    }
  }

  // Update address
  Future<void> updateUserAddress({
    required int addressId,
    required int userId,
    required String postalAddress,
    required String postalCode,
    required String physicalAddress,
    required String physicalCode,
  }) async {
    final url = Uri.parse("$baseUrl/useraddress/update");

    final body = jsonEncode({
      "addressid": addressId,
      "userid": userId,
      "postaladdress": postalAddress,
      "postalcode": postalCode,
      "physicaladdress": physicalAddress,
      "physicalcode": physicalCode,
    });

    final headers = {'Content-Type': 'application/json'};

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception("Failed to update address: ${response.body}");
    }
  }


}
