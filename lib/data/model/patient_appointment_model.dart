class Appointment {
  int? app_id;
  int? practitionerid;
  String? status;
  String? notes;
  DateTime? date;
  String? practitioner_occupation;
  String? practicenumber;
  String? statutorycouncil;
  int? practitioner_userid;
  String? practitioner_name;
  String? practitioner_surname;
  String? title;

  Appointment({
    this.app_id,
    this.practitionerid,
    this.status,
    this.notes,
    this.date,
    this.practitioner_occupation,
    this.practicenumber,
    this.statutorycouncil,
    this.practitioner_userid,
    this.practitioner_name,
    this.practitioner_surname,
    this.title
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      app_id: json['app_id'],
      practitionerid: json['practitionerid'],
      status: json['status'],
      notes: json['notes'],
      date : json['date'] != null
          ? DateTime.parse(json['date'])
          : null,
      practitioner_occupation: json['practitioner_occupation'],
      practicenumber: json['practicenumber'],
      statutorycouncil: json['statutorycouncil'],
      practitioner_userid: json['practitioner_userid'],
      practitioner_name: json['practitioner_name'],
      practitioner_surname: json['practitioner_surname'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "app_id": app_id,
    "practitionerid": practitionerid,
    "status": status,
    "notes": notes,
    'date': date?.toIso8601String(),
    'practitioner_occupation': practitioner_occupation,
    'practicenumber':practicenumber ,
    'statutorycouncil':statutorycouncil,
    'practitioner_userid': practitioner_userid,
    'practitioner_name': practitioner_name,
    'practitioner_surname': practitioner_surname,
    'title':title
  };
}
}