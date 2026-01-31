import 'dart:convert';

// GetVetExpert getVetExpertFromJson(String str) => GetVetExpert.fromJson(json.decode(str));

// String getVetExpertToJson(GetVetExpert data) => json.encode(data.toJson());

// class GetVetExpert {
//     int id;
//     String vetExpertName;
//     String vetExpertPassword;
//     String password;
//     String phonenumber;
//     String vetExpertEmail;
//     String profileImage;
//     String province;
//     String district;
//     String locality;
//     String vetExpertAddress;
//     String vetExpertPl;
//     int totalSemenStock;

//     GetVetExpert({
//         required this.id,
//         required this.vetExpertName,
//         required this.vetExpertPassword,
//         required this.password,
//         required this.phonenumber,
//         required this.vetExpertEmail,
//         required this.profileImage,
//         required this.province,
//         required this.district,
//         required this.locality,
//         required this.vetExpertAddress,
//         required this.vetExpertPl,
//         required this.totalSemenStock,
//     });

//     factory GetVetExpert.fromJson(Map<String, dynamic> json) => GetVetExpert(
//         id: json["id"],
//         vetExpertName: json["VetExpert_name"],
//         vetExpertPassword: json["VetExpert_password"],
//         password: json["password"],
//         phonenumber: json["phonenumber"],
//         vetExpertEmail: json["VetExpert_email"],
//         profileImage: json["profile_image"],
//         province: json["province"],
//         district: json["district"],
//         locality: json["locality"],
//         vetExpertAddress: json["VetExpert_address"],
//         vetExpertPl: json["VetExpert_PL"],
//         totalSemenStock: json["total_semen_stock"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "VetExpert_name": vetExpertName,
//         "VetExpert_password": vetExpertPassword,
//         "password": password,
//         "phonenumber": phonenumber,
//         "VetExpert_email": vetExpertEmail,
//         "profile_image": profileImage,
//         "province": province,
//         "district": district,
//         "locality": locality,
//         "VetExpert_address": vetExpertAddress,
//         "VetExpert_PL": vetExpertPl,
//         "total_semen_stock": totalSemenStock,
//     };
// }



// To parse this JSON data, do
//
//     final getVetExpert = getVetExpertFromJson(jsonString);

import 'dart:convert';

GetVetExpert getVetExpertFromJson(String str) => GetVetExpert.fromJson(json.decode(str));

String getVetExpertToJson(GetVetExpert data) => json.encode(data.toJson());

class GetVetExpert {
    int vetexpertsId;
    String vetexpertsName;
    String vetexpertsHashpassword;
    String vetexpertsPassword;
    String vetexpertsPhonenumber;
    String vetexpertsEmail;
    String vetexpertsProfileImage;
    String vetexpertsProvince;
    String vetexpertsDistrict;
    String vetexpertsLocality;
    String vetexpertsAddress;
    String vetexpertsLicense;
    int vetexpertsStatus;
    dynamic vetexpertsLocLat;
    dynamic vetexpertsLocLong;
    int totalSemenStock;

    GetVetExpert({
        required this.vetexpertsId,
        required this.vetexpertsName,
        required this.vetexpertsHashpassword,
        required this.vetexpertsPassword,
        required this.vetexpertsPhonenumber,
        required this.vetexpertsEmail,
        required this.vetexpertsProfileImage,
        required this.vetexpertsProvince,
        required this.vetexpertsDistrict,
        required this.vetexpertsLocality,
        required this.vetexpertsAddress,
        required this.vetexpertsLicense,
        required this.vetexpertsStatus,
        required this.vetexpertsLocLat,
        required this.vetexpertsLocLong,
        required this.totalSemenStock,
    });

    factory GetVetExpert.fromJson(Map<String, dynamic> json) => GetVetExpert(
        vetexpertsId: json["vetexperts_id"],
        vetexpertsName: json["vetexperts_name"],
        vetexpertsHashpassword: json["vetexperts_hashpassword"],
        vetexpertsPassword: json["vetexperts_password"],
        vetexpertsPhonenumber: json["vetexperts_phonenumber"],
        vetexpertsEmail: json["vetexperts_email"],
        vetexpertsProfileImage: json["vetexperts_profile_image"],
        vetexpertsProvince: json["vetexperts_province"],
        vetexpertsDistrict: json["vetexperts_district"],
        vetexpertsLocality: json["vetexperts_locality"],
        vetexpertsAddress: json["vetexperts__address"],
        vetexpertsLicense: json["vetexperts_license"],
        vetexpertsStatus: json["vetexperts_status"],
        vetexpertsLocLat: json["vetexperts_loc_lat"],
        vetexpertsLocLong: json["vetexperts_loc_long"],
        totalSemenStock: json["total_semen_stock"],
    );

    Map<String, dynamic> toJson() => {
        "vetexperts_id": vetexpertsId,
        "vetexperts_name": vetexpertsName,
        "vetexperts_hashpassword": vetexpertsHashpassword,
        "vetexperts_password": vetexpertsPassword,
        "vetexperts_phonenumber": vetexpertsPhonenumber,
        "vetexperts_email": vetexpertsEmail,
        "vetexperts_profile_image": vetexpertsProfileImage,
        "vetexperts_province": vetexpertsProvince,
        "vetexperts_district": vetexpertsDistrict,
        "vetexperts_locality": vetexpertsLocality,
        "vetexperts__address": vetexpertsAddress,
        "vetexperts_license": vetexpertsLicense,
        "vetexperts_status": vetexpertsStatus,
        "vetexperts_loc_lat": vetexpertsLocLat,
        "vetexperts_loc_long": vetexpertsLocLong,
        "total_semen_stock": totalSemenStock,
    };
}

