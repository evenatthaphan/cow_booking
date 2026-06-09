// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

VetExpert welcomeFromJson(String str) => VetExpert.fromJson(json.decode(str));

String welcomeToJson(VetExpert data) => json.encode(data.toJson());

class VetExpert {
  int    id;
  String vetExpertName;
  String vetExpertPassword;
  String password;
  String phonenumber;
  String vetExpertEmail;
  String profileImage;
  String province;
  String district;
  String locality;
  String vetExpertAddress;
  String vetExpertPl;
  int    totalSemenStock;
  double? locLat;   // vetexperts_loc_lat
  double? locLong;  // vetexperts_loc_long

  VetExpert({
    required this.id,
    required this.vetExpertName,
    required this.vetExpertPassword,
    required this.password,
    required this.phonenumber,
    required this.vetExpertEmail,
    required this.profileImage,
    required this.province,
    required this.district,
    required this.locality,
    required this.vetExpertAddress,
    required this.vetExpertPl,
    required this.totalSemenStock,
    this.locLat,
    this.locLong,
  });

  factory VetExpert.fromJson(Map<String, dynamic> json) => VetExpert(
        id:                 json['vetexperts_id']           ?? 0,
        vetExpertName:      json['vetexperts_name']         ?? '',
        vetExpertPassword:  json['vetexperts_hashpassword'] ?? '',
        password:           json['vetexperts_password']     ?? '',
        phonenumber:        json['vetexperts_phonenumber']  ?? '',
        vetExpertEmail:     json['vetexperts_email']        ?? '',
        profileImage:       json['vetexperts_profile_image'] ?? '',
        province:           json['vetexperts_province']     ?? '',
        district:           json['vetexperts_district']     ?? '',
        locality:           json['vetexperts_locality']     ?? '',
        vetExpertAddress:   json['vetexperts_address']      ?? '',
        vetExpertPl:        json['vetexperts_license']      ?? '',
        totalSemenStock:    json['totalSemenStock']         ?? 0,
        locLat:  json['vetexperts_loc_lat']  != null
            ? double.tryParse(json['vetexperts_loc_lat'].toString())
            : null,
        locLong: json['vetexperts_loc_long'] != null
            ? double.tryParse(json['vetexperts_loc_long'].toString())
            : null,
      );

      Map<String, dynamic> toJson() => {
        "id": id,
        "VetExpert_name": vetExpertName,
        "VetExpert_password": vetExpertPassword,
        "password": password,
        "phonenumber": phonenumber,
        "VetExpert_email": vetExpertEmail,
        "profile_image": profileImage,
        "province": province,
        "district": district,
        "locality": locality,
        "VetExpert_address": vetExpertAddress,
        "VetExpert_PL": vetExpertPl,
        "vetexperts_loc_lat": locLat,
        "vetexperts_loc_long": locLong,
    };

  VetExpert copyWith({
    int? id,
    String? vetExpertName,
    String? vetExpertPassword,
    String? password,
    String? phonenumber,
    String? vetExpertEmail,
    String? profileImage,
    String? province,
    String? district,
    String? locality,
    String? vetExpertAddress,
    String? vetExpertPl,
    int? totalSemenStock,
    double? locLat,
    double? locLong,
  }) {
    return VetExpert(
      id: id ?? this.id,
      vetExpertName: vetExpertName ?? this.vetExpertName,
      vetExpertPassword: vetExpertPassword ?? this.vetExpertPassword,
      password: password ?? this.password,
      phonenumber: phonenumber ?? this.phonenumber,
      vetExpertEmail: vetExpertEmail ?? this.vetExpertEmail,
      profileImage: profileImage ?? this.profileImage,
      province: province ?? this.province,
      district: district ?? this.district,
      locality: locality ?? this.locality,
      vetExpertAddress: vetExpertAddress ?? this.vetExpertAddress,
      vetExpertPl: vetExpertPl ?? this.vetExpertPl,
      totalSemenStock: totalSemenStock ?? this.totalSemenStock,
      locLat: locLat ?? this.locLat,
      locLong: locLong ?? this.locLong,
    );
  }
}

