// To parse this JSON data, do
//
//     final bullStock = bullStockFromJson(jsonString);

import 'dart:convert';

Map<String, List<BullStock>> bullStockFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) => MapEntry<String, List<BullStock>>(
        k, List<BullStock>.from(v.map((x) => BullStock.fromJson(x)))));

String bullStockToJson(Map<String, List<BullStock>> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(
        k, List<dynamic>.from(v.map((x) => x.toJson())))));

class BullStock {
  int bullseriesId; // id ของวัว
  String bullname;
  String bullbreed;
  String characteristics;
  int farmId;
  String farmName;
  int pricePerDose;
  int semenStock;
  int vetBullId; // vetBullId

  BullStock({
    required this.bullseriesId,
    required this.bullname,
    required this.bullbreed,
    required this.characteristics,
    required this.farmId,
    required this.farmName,
    required this.pricePerDose,
    required this.semenStock,
    required this.vetBullId,
  });

  // factory BullStock.fromJson(Map<String, dynamic> json) => BullStock(
  //       bullseriesId: json["bullseries_id"],
  //       bullname: json["Bullname"],
  //       bullbreed: json["Bullbreed"],
  //       characteristics: json["characteristics"],
  //       farmId: json["farm_id"],
  //       farmName: json["farm_name"],
  //       pricePerDose: json["price_per_dose"],
  //       semenStock: json["semen_stock"],
  //       vetBullId: json["vet_bull_id"], //
  //     );

  factory BullStock.fromJson(Map<String, dynamic> json) {
    print("PARSING BULL: $json"); 
    return BullStock(
      bullseriesId: (json["bullseries_id"] ?? 0) as int,
      bullname:     json["Bullname"]     ?? json["bulls_name"]  ?? '',
      bullbreed:    json["Bullbreed"]    ?? json["bulls_breed"] ?? '',
      characteristics: json["characteristics"] ?? '',
      farmId:       (json["farm_id"]       ?? 0) as int,
      farmName:     json["farm_name"]      ?? '',
      pricePerDose: (json["price_per_dose"] ?? 0) as int,
      semenStock:   (json["semen_stock"]    ?? 0) as int,
      vetBullId:    (json["vet_bull_id"]    ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        "bullseries_id": bullseriesId,
        "Bullname": bullname,
        "Bullbreed": bullbreed,
        "characteristics": characteristics,
        "farm_id": farmId,
        "farm_name": farmName,
        "price_per_dose": pricePerDose,
        "semen_stock": semenStock,
        "vet_bull_id": vetBullId,
      };
}
