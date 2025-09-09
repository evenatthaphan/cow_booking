// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    int id;
    String farmName;
    String farmPassword;
    String phonenumber;
    String farmerEmail;
    String profileImage;
    String farmAddress;
    String province;
    String district;
    String locality;

    Welcome({
        required this.id,
        required this.farmName,
        required this.farmPassword,
        required this.phonenumber,
        required this.farmerEmail,
        required this.profileImage,
        required this.farmAddress,
        required this.province,
        required this.district,
        required this.locality,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        id: json["id"],
        farmName: json["farm_name"],
        farmPassword: json["farm_password"],
        phonenumber: json["phonenumber"],
        farmerEmail: json["farmer_email"],
        profileImage: json["profile_image"],
        farmAddress: json["farm_address"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "farm_name": farmName,
        "farm_password": farmPassword,
        "phonenumber": phonenumber,
        "farmer_email": farmerEmail,
        "profile_image": profileImage,
        "farm_address": farmAddress,
        "province": province,
        "district": district,
        "locality": locality,
    };
}
