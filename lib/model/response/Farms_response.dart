import 'dart:convert';

Map<String, List<FarmbullRequestResponse>> farmbullRequestResponseFromJson(
        String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, List<FarmbullRequestResponse>>(
            k,
            List<FarmbullRequestResponse>.from(
                v.map((x) => FarmbullRequestResponse.fromJson(x)))));

String farmbullRequestResponseToJson(
        Map<String, List<FarmbullRequestResponse>> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(
        k, List<dynamic>.from(v.map((x) => x.toJson())))));

class FarmbullRequestResponse {
  int id;
  String bullname;
  String bullbreed;
  int bullage;
  String characteristics;
  int farmId;
  int pricePerDose;
  int semenStock;
  String contestRecords;
  int addedBy;
  String farmName;
  String province;
  String district;
  String locality;
  String address;
  String image1;
  String image2;
  String image3;
  String image4;
  String image5;
  List<String> images;

  FarmbullRequestResponse({
    required this.id,
    required this.bullname,
    required this.bullbreed,
    required this.bullage,
    required this.characteristics,
    required this.farmId,
    required this.pricePerDose,
    required this.semenStock,
    required this.contestRecords,
    required this.addedBy,
    required this.farmName,
    required this.province,
    required this.district,
    required this.locality,
    required this.address,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.image4,
    required this.image5,
    required this.images,
  });

  factory FarmbullRequestResponse.fromJson(Map<String, dynamic> json) =>
      FarmbullRequestResponse(
        id: json["id"],
        bullname: json["Bullname"],
        bullbreed: json["Bullbreed"],
        bullage: json["Bullage"],
        characteristics: json["characteristics"],
        farmId: json["farm_id"],
        pricePerDose: json["price_per_dose"],
        semenStock: json["semen_stock"],
        contestRecords: json["contest_records"],
        addedBy: json["added_by"],
        farmName: json["farm_name"],
        province: json["province"],
        district: json["district"],
        locality: json["locality"],
        address: json["address"],
        image1: json["image1"] ?? "",
        image2: json["image2"] ?? "",
        image3: json["image3"] ?? "",
        image4: json["image4"] ?? "",
        image5: json["image5"] ?? "",
        images: [
          if (json["image1"] != null && json["image1"].toString().isNotEmpty)
            json["image1"],
          if (json["image2"] != null && json["image2"].toString().isNotEmpty)
            json["image2"],
          if (json["image3"] != null && json["image3"].toString().isNotEmpty)
            json["image3"],
          if (json["image4"] != null && json["image4"].toString().isNotEmpty)
            json["image4"],
          if (json["image5"] != null && json["image5"].toString().isNotEmpty)
            json["image5"],
        ],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Bullname": bullname,
        "Bullbreed": bullbreed,
        "Bullage": bullage,
        "characteristics": characteristics,
        "farm_id": farmId,
        "price_per_dose": pricePerDose,
        "semen_stock": semenStock,
        "contest_records": contestRecords,
        "added_by": addedBy,
        "farm_name": farmName,
        "province": province,
        "district": district,
        "locality": locality,
        "address": address,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "image4": image4,
        "image5": image5,
        "images": List<dynamic>.from(images.map((x) => x)),
      };
}
