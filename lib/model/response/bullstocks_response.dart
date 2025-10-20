// To parse this JSON data, do
//
//     final bullStock = bullStockFromJson(jsonString);

import 'dart:convert';

Map<String, List<BullStock>> bullStockFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, List<BullStock>>(k, List<BullStock>.from(v.map((x) => BullStock.fromJson(x)))));

String bullStockToJson(Map<String, List<BullStock>> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x.toJson())))));

class BullStock {
    int bullId;
    String bullname;
    String bullbreed;
    String characteristics;
    int farmId;
    String farmName;
    int pricePerDose;
    int semenStock;

    BullStock({
        required this.bullId,
        required this.bullname,
        required this.bullbreed,
        required this.characteristics,
        required this.farmId,
        required this.farmName,
        required this.pricePerDose,
        required this.semenStock,
    });

    factory BullStock.fromJson(Map<String, dynamic> json) => BullStock(
        bullId: json["bull_id"],
        bullname: json["Bullname"],
        bullbreed: json["Bullbreed"],
        characteristics: json["characteristics"],
        farmId: json["farm_id"],
        farmName: json["farm_name"],
        pricePerDose: json["price_per_dose"],
        semenStock: json["semen_stock"],
    );

    Map<String, dynamic> toJson() => {
        "bull_id": bullId,
        "Bullname": bullname,
        "Bullbreed": bullbreed,
        "characteristics": characteristics,
        "farm_id": farmId,
        "farm_name": farmName,
        "price_per_dose": pricePerDose,
        "semen_stock": semenStock,
    };
}
