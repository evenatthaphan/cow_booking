// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

VetExpert welcomeFromJson(String str) => VetExpert.fromJson(json.decode(str));

String welcomeToJson(VetExpert data) => json.encode(data.toJson());

class VetExpert {
    int id;
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
    int totalSemenStock;
    final String? vetexperts_loc_lat;
    final String? vetexperts_loc_long;

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
        this.totalSemenStock = 0,
        this.vetexperts_loc_lat,
        this.vetexperts_loc_long,
    });

    // factory VetExpert.fromJson(Map<String, dynamic> json) => VetExpert(
    //     id: json["id"],
    //     vetExpertName: json["VetExpert_name"],
    //     vetExpertPassword: json["VetExpert_password"],
    //     password: json["password"],
    //     phonenumber: json["phonenumber"],
    //     vetExpertEmail: json["VetExpert_email"],
    //     profileImage: json["profile_image"],
    //     province: json["province"],
    //     district: json["district"],
    //     locality: json["locality"],
    //     vetExpertAddress: json["VetExpert_address"],
    //     vetExpertPl: json["VetExpert_PL"],
    // );
    factory VetExpert.fromJson(Map<String, dynamic> json) => VetExpert(
      id: json["vetexperts_id"],
      vetExpertName: json["vetexperts_name"],
      vetExpertPassword: json["vetexperts_hashpassword"],
      password: json["vetexperts_password"] ?? "",
      phonenumber: json["vetexperts_phonenumber"],
      vetExpertEmail: json["vetexperts_email"],
      profileImage: json["vetexperts_profile_image"] ?? "",
      province: json["vetexperts_province"],
      district: json["vetexperts_district"],
      locality: json["vetexperts_locality"],
      vetExpertAddress: json["vetexperts__address"],
      vetExpertPl: json["vetexperts_license"],
      totalSemenStock: json["totalSemenStock"] ?? 0,
      vetexperts_loc_lat: json["vetexperts_loc_lat"],
      vetexperts_loc_long: json["vetexperts_loc_long"],
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
        "vetexperts_loc_lat": vetexperts_loc_lat,
        "vetexperts_loc_long": vetexperts_loc_long,
    };
}
