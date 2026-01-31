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
    });

    factory VetExpert.fromJson(Map<String, dynamic> json) => VetExpert(
        id: json["id"],
        vetExpertName: json["VetExpert_name"],
        vetExpertPassword: json["VetExpert_password"],
        password: json["password"],
        phonenumber: json["phonenumber"],
        vetExpertEmail: json["VetExpert_email"],
        profileImage: json["profile_image"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
        vetExpertAddress: json["VetExpert_address"],
        vetExpertPl: json["VetExpert_PL"],
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
    };
}
