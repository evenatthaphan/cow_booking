import 'dart:convert';

GetVetExpert getVetExpertFromJson(String str) => GetVetExpert.fromJson(json.decode(str));

String getVetExpertToJson(GetVetExpert data) => json.encode(data.toJson());

class GetVetExpert {
    int id;
    String vetExpertName;
    String vetExpertPassword;
    String phonenumber;
    String vetExpertEmail;
    String profileImage;
    String province;
    String district;
    String locality;
    String vetExpertAddress;
    String vetExpertPl;
    int totalSemenStock;

    GetVetExpert({
        required this.id,
        required this.vetExpertName,
        required this.vetExpertPassword,
        required this.phonenumber,
        required this.vetExpertEmail,
        required this.profileImage,
        required this.province,
        required this.district,
        required this.locality,
        required this.vetExpertAddress,
        required this.vetExpertPl,
        required this.totalSemenStock,
    });

    factory GetVetExpert.fromJson(Map<String, dynamic> json) => GetVetExpert(
        id: json["id"],
        vetExpertName: json["VetExpert_name"],
        vetExpertPassword: json["VetExpert_password"],
        phonenumber: json["phonenumber"],
        vetExpertEmail: json["VetExpert_email"],
        profileImage: json["profile_image"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
        vetExpertAddress: json["VetExpert_address"],
        vetExpertPl: json["VetExpert_PL"],
        totalSemenStock: json["total_semen_stock"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "VetExpert_name": vetExpertName,
        "VetExpert_password": vetExpertPassword,
        "phonenumber": phonenumber,
        "VetExpert_email": vetExpertEmail,
        "profile_image": profileImage,
        "province": province,
        "district": district,
        "locality": locality,
        "VetExpert_address": vetExpertAddress,
        "VetExpert_PL": vetExpertPl,
        "total_semen_stock": totalSemenStock,
    };
}
