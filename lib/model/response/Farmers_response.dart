// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Farmers welcomeFromJson(String str) => Farmers.fromJson(json.decode(str));

String welcomeToJson(Farmers data) => json.encode(data.toJson());

class Farmers {
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

    Farmers({
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

    factory Farmers.fromJson(Map<String, dynamic> json) => Farmers(
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
