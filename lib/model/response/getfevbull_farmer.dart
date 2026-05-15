// To parse this JSON data, do
//
//     final fevbull = fevbullFromJson(jsonString);

import 'dart:convert';

List<Fevbull> fevbullFromJson(String str) => List<Fevbull>.from(json.decode(str).map((x) => Fevbull.fromJson(x)));

String fevbullToJson(List<Fevbull> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Fevbull {
    int likeId;
    int refFarmersId;
    int refBullsId;
    String bullsName;
    String bullsBreed;
    String bullsCharacteristics;
    String bullsImage;

    Fevbull({
        required this.likeId,
        required this.refFarmersId,
        required this.refBullsId,
        required this.bullsName,
        required this.bullsBreed,
        required this.bullsCharacteristics,
        required this.bullsImage,
    });

    factory Fevbull.fromJson(Map<String, dynamic> json) => Fevbull(
        likeId: json["like_id"],
        refFarmersId: json["ref_farmers_id"],
        refBullsId: json["ref_bulls_id"],
        bullsName: json["bulls_name"],
        bullsBreed: json["bulls_breed"],
        bullsCharacteristics: json["bulls_characteristics"],
        bullsImage: json["bulls_image"],
    );

    Map<String, dynamic> toJson() => {
        "like_id": likeId,
        "ref_farmers_id": refFarmersId,
        "ref_bulls_id": refBullsId,
        "bulls_name": bullsName,
        "bulls_breed": bullsBreed,
        "bulls_characteristics": bullsCharacteristics,
        "bulls_image": bullsImage,
    };
}
