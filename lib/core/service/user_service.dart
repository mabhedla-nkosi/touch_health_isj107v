import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  String? name;
  int? userid;
  String? surname;
  String? contactinfo;
  String? email;
  String? password;
  String? id_passportnumber;
  String? gender;
  String? dob;
  String? nationality;

  User({
    this.userid,  
    this.name, 
    this.surname, 
    this.contactinfo, 
    this.email, 
    this.password, 
    this.id_passportnumber, 
    this.gender,
    this.dob,
    this.nationality});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userid: json['userid'],
      name: json['name'],
      surname: json['surname'],
      contactinfo: json['contactinfo'],
      email: json['email'],
      password: json['password'],
      id_passportnumber: json['id_passportnumber'],
      gender: json['gender'],
      dob: json['dob'],
      nationality: json['nationality'],
    );
  }

  @override
  String toString() {
    return 'User(userId: $userid, name: $name, surname: $surname, email: $email, gender: $gender)';
  }
}

class UserService {
  final String baseUrl = "http://10.0.2.2:5000";
  //final String baseUrl = "https://postgres-api-hrd8.onrender.com"; 
  // for Android emulator
  // use http://localhost:5000 if on iOS simulator or web

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<User> addUser(String name, int age) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "age": age}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add user");
    }
  }
}
