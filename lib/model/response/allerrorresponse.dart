import 'dart:convert';

Allerrorresponseget allerrorresponsegetFromJson(String str) => Allerrorresponseget.fromJson(json.decode(str));

String allerrorresponsegetToJson(Allerrorresponseget data) => json.encode(data.toJson());

class Allerrorresponseget {
    String msg;

    Allerrorresponseget({
        required this.msg,
    });

    factory Allerrorresponseget.fromJson(Map<String, dynamic> json) => Allerrorresponseget(
        msg: json["msg"],
    );

    Map<String, dynamic> toJson() => {
        "msg": msg,
    };
}