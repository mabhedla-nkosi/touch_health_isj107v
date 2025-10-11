class UserDataModel {
  String? name;
  String? userId;
  String? surname;
  String? phone;
  String? email;
  String? password;
  String? id_passportnumber;
  String? gender;
  String? dob;
  String? nationality;

  UserDataModel({
    this.name,
    this.userId,
    this.surname,
    this.phone,
    this.email,
    this.password,
    this.id_passportnumber,
    this.gender,
    this.dob,
    this.nationality,
  });

  UserDataModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
      userId = json['userid'] ?? '',
      surname = json['surname'] ?? '',
      phone = json['phone'] ?? '',
      email = json['email'] ?? '',
      password = json['password'] ?? '',
      id_passportnumber = json['id_passportnumber'] ?? '',
      gender = json['gender'] ?? '',
      dob = json['dob'] ?? '',
      nationality = json['nationality'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userid': userId,
      'surname': surname,
      'phone': phone,
      'email': email,
      'password': password,
      'id_passportnumber': id_passportnumber,
      'gender': gender,
      'dob': dob,
      'nationality': nationality,
    };
  }

  @override
  String toString() {
    return 'User(userId: $userId, name: $name, surname: $surname, email: $email, gender: $gender)';
  }
}
