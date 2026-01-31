// To parse this JSON data, do
//
//     final bookingResponse = bookingResponseFromJson(jsonString);

// import 'dart:convert';

// List<BookingResponse> bookingResponseFromJson(String str) => List<BookingResponse>.from(json.decode(str).map((x) => BookingResponse.fromJson(x)));

// String bookingResponseToJson(List<BookingResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class BookingResponse {
//     int bookingId;
//     int farmerId;
//     String farmerName;
//     int vetExpertId;
//     String vetName;
//     int vetBullId;
//     String bullname;
//     String bullbreed;
//     int dose;
//     DateTime scheduleDate;
//     String scheduleTime;
//     String detailBull;
//     String status;
//     dynamic vetNotes;
//     DateTime createdAt;

//     BookingResponse({
//         required this.bookingId,
//         required this.farmerId,
//         required this.farmerName,
//         required this.vetExpertId,
//         required this.vetName,
//         required this.vetBullId,
//         required this.bullname,
//         required this.bullbreed,
//         required this.dose,
//         required this.scheduleDate,
//         required this.scheduleTime,
//         required this.detailBull,
//         required this.status,
//         required this.vetNotes,
//         required this.createdAt,
//     });

//     factory BookingResponse.fromJson(Map<String, dynamic> json) => BookingResponse(
//         bookingId: json["booking_id"],
//         farmerId: json["farmer_id"],
//         farmerName: json["farmer_name"],
//         vetExpertId: json["vet_expert_id"],
//         vetName: json["vet_name"],
//         vetBullId: json["vet_bull_id"],
//         bullname: json["bullname"],
//         bullbreed: json["bullbreed"],
//         dose: json["dose"],
//         scheduleDate: DateTime.parse(json["schedule_date"]),
//         scheduleTime: json["schedule_time"],
//         detailBull: json["detailBull"],
//         status: json["status"],
//         vetNotes: json["vet_notes"],
//         createdAt: DateTime.parse(json["created_at"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "booking_id": bookingId,
//         "farmer_id": farmerId,
//         "farmer_name": farmerName,
//         "vet_expert_id": vetExpertId,
//         "vet_name": vetName,
//         "vet_bull_id": vetBullId,
//         "bullname": bullname,
//         "bullbreed": bullbreed,
//         "dose": dose,
//         "schedule_date": scheduleDate.toIso8601String(),
//         "schedule_time": scheduleTime,
//         "detailBull": detailBull,
//         "status": status,
//         "vet_notes": vetNotes,
//         "created_at": createdAt.toIso8601String(),
//     };
// }


// To parse this JSON data, do
//
//     final bookingResponse = bookingResponseFromJson(jsonString);

import 'dart:convert';

List<BookingResponse> bookingResponseFromJson(String str) => List<BookingResponse>.from(json.decode(str).map((x) => BookingResponse.fromJson(x)));

String bookingResponseToJson(List<BookingResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookingResponse {
    int queueBookingsId;
    int refFarmersId;
    String farmersName;
    int refVetexpertsId;
    String vetexpertsName;
    int refBullsId;
    String bullsName;
    String bullsBreed;
    int bookingsDose;
    DateTime scheduleDate;
    String scheduleTime;
    String bookingsDetailBull;
    String bookingsStatus;
    dynamic bookingsVetNotes;
    DateTime createdAt;

    BookingResponse({
        required this.queueBookingsId,
        required this.refFarmersId,
        required this.farmersName,
        required this.refVetexpertsId,
        required this.vetexpertsName,
        required this.refBullsId,
        required this.bullsName,
        required this.bullsBreed,
        required this.bookingsDose,
        required this.scheduleDate,
        required this.scheduleTime,
        required this.bookingsDetailBull,
        required this.bookingsStatus,
        required this.bookingsVetNotes,
        required this.createdAt,
    });

    factory BookingResponse.fromJson(Map<String, dynamic> json) => BookingResponse(
        queueBookingsId: json["queue_bookings_id"],
        refFarmersId: json["ref_farmers_id"],
        farmersName: json["farmers_name"],
        refVetexpertsId: json["ref_vetexperts_id"],
        vetexpertsName: json["vetexperts_name"],
        refBullsId: json["ref_bulls_id"],
        bullsName: json["bulls_name"],
        bullsBreed: json["bulls_breed"],
        bookingsDose: json["bookings_dose"],
        scheduleDate: DateTime.parse(json["schedule_date"]),
        scheduleTime: json["schedule_time"],
        bookingsDetailBull: json["bookings_detail_bull"],
        bookingsStatus: json["bookings_status"],
        bookingsVetNotes: json["bookings_vet_notes"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "queue_bookings_id": queueBookingsId,
        "ref_farmers_id": refFarmersId,
        "farmers_name": farmersName,
        "ref_vetexperts_id": refVetexpertsId,
        "vetexperts_name": vetexpertsName,
        "ref_bulls_id": refBullsId,
        "bulls_name": bullsName,
        "bulls_breed": bullsBreed,
        "bookings_dose": bookingsDose,
        "schedule_date": scheduleDate.toIso8601String(),
        "schedule_time": scheduleTime,
        "bookings_detail_bull": bookingsDetailBull,
        "bookings_status": bookingsStatus,
        "bookings_vet_notes": bookingsVetNotes,
        "created_at": createdAt.toIso8601String(),
    };
}

