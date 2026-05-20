

import 'dart:convert';

List<AdminResponse> AdminResponseFromJson(String str) => List<AdminResponse>.from(json.decode(str).map((x) => AdminResponse.fromJson(x)));

String AdminResponseToJson(List<AdminResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdminResponse {
    int adminsId;
    String adminsName;
    String adminsEmail;
    String adminsPassword;
    String adminsPhonenumber;
    String adminsAddress;
    int adminType;
    int mustChangePassword;
    DateTime createdAt;
    DateTime updatedAt;

    // handlers
    bool get isMaster => adminType == 1;
    bool get isSuper  => adminType == 2;
    bool get isAdmin  => adminType == 3;

    // เช็คว่ามีสิทธิ์จัดการ Admin มั้ย (Master + Super)
    bool get canManageAdmin => adminType <= 2;

    AdminResponse({
        required this.adminsId,
        required this.adminsName,
        required this.adminsEmail,
        required this.adminsPassword,
        required this.adminsPhonenumber,
        required this.adminsAddress,
        required this.adminType,
        required this.mustChangePassword,
        required this.createdAt,
        required this.updatedAt,
    });

    // factory AdminResponse.fromJson(Map<String, dynamic> json) => AdminResponse(
    //     adminsId: json["admins_id"],
    //     adminsName: json["admins_name"],
    //     adminsEmail: json["admins_email"],
    //     adminsPassword: json["admins_password"],
    //     adminsPhonenumber: json["admins_phonenumber"],
    //     adminsAddress: json["admins_address"],
    //     adminType: json["admin_type"],
    //     mustChangePassword: json["must_change_password"],
    //     createdAt: DateTime.parse(json["created_at"]),
    //     updatedAt: DateTime.parse(json["updated_at"]),
    // );

    factory AdminResponse.fromJson(Map<String, dynamic> json) => AdminResponse(
        adminsId:           json["admins_id"]            ?? 0,
        adminsName:         json["admins_name"]          ?? '',
        adminsEmail:        json["admins_email"]         ?? '',
        adminsPassword:     json["admins_password"]      ?? '',
        adminsPhonenumber:  json["admins_phonenumber"]   ?? '',
        adminsAddress:      json["admins_address"]       ?? '',   
        adminType:          json["admin_type"]           ?? 3,
        mustChangePassword: json["must_change_password"] ?? 0,
        createdAt:  json["created_at"]  != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt:  json["updated_at"]  != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
    );


    Map<String, dynamic> toJson() => {
        "admins_id": adminsId,
        "admins_name": adminsName,
        "admins_email": adminsEmail,
        "admins_password": adminsPassword,
        "admins_phonenumber": adminsPhonenumber,
        "admins_address": adminsAddress,
        "admin_type": adminType,
        "must_change_password": mustChangePassword,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}