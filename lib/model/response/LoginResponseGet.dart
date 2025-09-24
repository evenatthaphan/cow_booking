// To parse this JSON data, do
//
//     final loginResponseGet = loginResponseGetFromJson(jsonString);

import 'dart:convert';

LoginResponseGet loginResponseGetFromJson(String str) => LoginResponseGet.fromJson(json.decode(str));

String loginResponseGetToJson(LoginResponseGet data) => json.encode(data.toJson());

class LoginResponseGet {
    String role;
    String message;
    User user;

    LoginResponseGet({
        required this.role,
        required this.message,
        required this.user,
    });

    factory LoginResponseGet.fromJson(Map<String, dynamic> json) => LoginResponseGet(
        role: json["role"],
        message: json["message"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "role": role,
        "message": message,
        "user": user.toJson(),
    };
}

class User {
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

    User({
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

    factory User.fromJson(Map<String, dynamic> json) => User(
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
