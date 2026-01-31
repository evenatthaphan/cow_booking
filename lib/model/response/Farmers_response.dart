// To parse this JSON data, do
//
//     final farmers = farmersFromJson(jsonString);

import 'dart:convert';

List<Farmers> farmersFromJson(String str) => List<Farmers>.from(json.decode(str).map((x) => Farmers.fromJson(x)));

String farmersToJson(List<Farmers> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Farmers {
    int farmersId;
    String farmersName;
    String farmesHashpassword;
    String farmersPassword;
    String farmersPhonenumber;
    String farmersEmail;
    String farmersProfileImage;
    String farmersAddress;
    String farmersProvince;
    String farmersDistrict;
    String farnersLocality;
    dynamic farmersLocLat;
    dynamic farmersLocLong;

    Farmers({
        required this.farmersId,
        required this.farmersName,
        required this.farmesHashpassword,
        required this.farmersPassword,
        required this.farmersPhonenumber,
        required this.farmersEmail,
        required this.farmersProfileImage,
        required this.farmersAddress,
        required this.farmersProvince,
        required this.farmersDistrict,
        required this.farnersLocality,
        required this.farmersLocLat,
        required this.farmersLocLong,
    });

    factory Farmers.fromJson(Map<String, dynamic> json) => Farmers(
        farmersId: json["farmers_id"],
        farmersName: json["farmers_name"],
        farmesHashpassword: json["farmes_hashpassword"],
        farmersPassword: json["farmers_password"],
        farmersPhonenumber: json["farmers_phonenumber"],
        farmersEmail: json["farmers_email"],
        farmersProfileImage: json["farmers_profile_image"],
        farmersAddress: json["farmers_address"],
        farmersProvince: json["farmers_province"],
        farmersDistrict: json["farmers_district"],
        farnersLocality: json["farners_locality"],
        farmersLocLat: json["farmers_loc_lat"],
        farmersLocLong: json["farmers_loc_long"],
    );

    Map<String, dynamic> toJson() => {
        "farmers_id": farmersId,
        "farmers_name": farmersName,
        "farmes_hashpassword": farmesHashpassword,
        "farmers_password": farmersPassword,
        "farmers_phonenumber": farmersPhonenumber,
        "farmers_email": farmersEmail,
        "farmers_profile_image": farmersProfileImage,
        "farmers_address": farmersAddress,
        "farmers_province": farmersProvince,
        "farmers_district": farmersDistrict,
        "farners_locality": farnersLocality,
        "farmers_loc_lat": farmersLocLat,
        "farmers_loc_long": farmersLocLong,
    };
}
