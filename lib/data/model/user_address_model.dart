import 'dart:convert';

class UserAddressDataModel {
  int? addressid;
  int? userid;
  String? postaladdress;
  String? postalcode;
  String? physicaladdress;
  String? physicalcode;

  UserAddressDataModel({
    this.addressid,
    this.userid,
    this.postaladdress,
    this.postalcode,
    this.physicaladdress,
    this.physicalcode,
  });

  UserAddressDataModel.fromJson(Map<String, dynamic> json)
      : addressid = json['addressid'] ?? 0,
        userid = json['userid'] ?? 0,
        postaladdress = json['postaladdress'] ?? '',
        postalcode = json['postalcode'] ?? '',
        physicaladdress = json['physicaladdress'] ?? '',
        physicalcode = json['physicalcode'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'addressid': addressid,
      'userid': userid,
      'postaladdress': postaladdress,
      'postalcode': postalcode,
      'physicaladdress': physicaladdress,
      'physicalcode': physicalcode,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
