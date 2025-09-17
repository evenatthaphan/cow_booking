// To parse this JSON data, do
//
//     final farmersRegsiterRequestPost = farmersRegsiterRequestPostFromJson(jsonString);

import 'dart:convert';

FarmersRegsiterRequestPost farmersRegsiterRequestPostFromJson(String str) => FarmersRegsiterRequestPost.fromJson(json.decode(str));

String farmersRegsiterRequestPostToJson(FarmersRegsiterRequestPost data) => json.encode(data.toJson());

class FarmersRegsiterRequestPost {
    String farmName;
    String farmPassword;
    String phonenumber;
    String farmerEmail;
    String farmAddress;
    String province;
    String district;
    String locality;

    FarmersRegsiterRequestPost({
        required this.farmName,
        required this.farmPassword,
        required this.phonenumber,
        required this.farmerEmail,
        required this.farmAddress,
        required this.province,
        required this.district,
        required this.locality,
    });

    factory FarmersRegsiterRequestPost.fromJson(Map<String, dynamic> json) => FarmersRegsiterRequestPost(
        farmName: json["farm_name"],
        farmPassword: json["farm_password"],
        phonenumber: json["phonenumber"],
        farmerEmail: json["farmer_email"],
        farmAddress: json["farm_address"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
    );

    Map<String, dynamic> toJson() => {
        "farm_name": farmName,
        "farm_password": farmPassword,
        "phonenumber": phonenumber,
        "farmer_email": farmerEmail,
        "farm_address": farmAddress,
        "province": province,
        "district": district,
        "locality": locality,
    };
}
