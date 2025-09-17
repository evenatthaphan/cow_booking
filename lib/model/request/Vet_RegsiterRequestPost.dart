// To parse this JSON data, do
//
//     final vetRegsiterRequestPost = vetRegsiterRequestPostFromJson(jsonString);

import 'dart:convert';

VetRegsiterRequestPost vetRegsiterRequestPostFromJson(String str) => VetRegsiterRequestPost.fromJson(json.decode(str));

String vetRegsiterRequestPostToJson(VetRegsiterRequestPost data) => json.encode(data.toJson());

class VetRegsiterRequestPost {
    String vetExpertName;
    String vetExpertPassword;
    String phonenumber;
    String vetExpertEmail;
    String province;
    String district;
    String locality;
    String vetExpertAddress;
    String vetExpertPl;

    VetRegsiterRequestPost({
        required this.vetExpertName,
        required this.vetExpertPassword,
        required this.phonenumber,
        required this.vetExpertEmail,
        required this.province,
        required this.district,
        required this.locality,
        required this.vetExpertAddress,
        required this.vetExpertPl,
    });

    factory VetRegsiterRequestPost.fromJson(Map<String, dynamic> json) => VetRegsiterRequestPost(
        vetExpertName: json["VetExpert_name"],
        vetExpertPassword: json["VetExpert_password"],
        phonenumber: json["phonenumber"],
        vetExpertEmail: json["VetExpert_email"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
        vetExpertAddress: json["VetExpert_address"],
        vetExpertPl: json["VetExpert_PL"],
    );

    Map<String, dynamic> toJson() => {
        "VetExpert_name": vetExpertName,
        "VetExpert_password": vetExpertPassword,
        "phonenumber": phonenumber,
        "VetExpert_email": vetExpertEmail,
        "province": province,
        "district": district,
        "locality": locality,
        "VetExpert_address": vetExpertAddress,
        "VetExpert_PL": vetExpertPl,
    };
}
