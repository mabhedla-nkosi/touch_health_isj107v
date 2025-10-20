class Vitals {
  int? vitalid;
  int? systolic;
  int? diastolic;
  int? heartrate;
  double? temperature;
  DateTime? vitalsdate;
  int? practitionerid;
  String? practitioner_occupation;
  int? practitioner_userid;
  String? practitioner_name;
  String? practitioner_surname;
  String? title;

  Vitals({
    this.vitalid,
    this.systolic,
    this.diastolic,
    this.heartrate,
    this.temperature,
    this.vitalsdate,
    this.practitionerid,
    this.practitioner_occupation,
    this.practitioner_userid,
    this.practitioner_name,
    this.practitioner_surname,
    this.title
  });

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      vitalid: json['vitalid'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      heartrate: json['heartrate'],
      temperature: (json['temperature'] != null)
          ? double.tryParse(json['temperature'].toString())
          : null,
      vitalsdate: json['vitalsdate'] != null
          ? DateTime.parse(json['vitalsdate'])
          : null,
      practitionerid: json['practitionerid'],
      practitioner_occupation: json['practitioner_occupation'],
      practitioner_userid: json['practitioner_userid'],
      practitioner_name: json['practitioner_name'],
      practitioner_surname: json['practitioner_surname'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vitalid": vitalid,
      "systolic": systolic,
      "diastolic": diastolic,
      "heartrate": heartrate,
      "temperature": temperature,
      "vitalsdate": vitalsdate?.toIso8601String(),
      "practitionerid": practitionerid,
      "practitioner_occupation": practitioner_occupation,
      "practitioner_userid": practitioner_userid,
      "practitioner_name": practitioner_name,
      "practitioner_surname": practitioner_surname,
      'title':title
    };
  }
}