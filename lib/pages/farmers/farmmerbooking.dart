import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/farmers/farmerNavbar.dart';
import 'package:cow_booking/pages/farmers/farmerprofile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Farmmerbookingpage extends StatefulWidget {
  const Farmmerbookingpage({super.key});

  @override
  State<Farmmerbookingpage> createState() => _FarmmerbookingpageState();
}

class _FarmmerbookingpageState extends State<Farmmerbookingpage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "คิวของฉัน",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            const TabBar(
              indicatorColor: Colors.green,
              labelColor: Color.fromARGB(255, 25, 71, 37),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "ส่งคำขอแล้ว"),
                Tab(text: "ตอบรับแล้ว"),
                Tab(text: "ถูกปฏิเสธ"),
                //Tab(text: "ยกเลิกแล้ว"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingList(),
                  const Center(child: Text("ยังไม่มีรายการตอบรับแล้ว")),
                  const Center(child: Text("ยังไม่มีรายการที่ปฏิเสธ")),
                  //const Center(child: Text("ยังไม่มีรายการที่ยกเลิก")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<BookingResponse>> fetchPendingBookings(int farmerId) async {
    final response = await http.get(
      Uri.parse('$apiEndpoint/queuebook/bookings/farmer?farmer_id=$farmerId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // only status = 'pending'
      final pendingBookings = data
          .map((e) => BookingResponse.fromJson(e))
          .where((b) => b.status == 'pending')
          .toList();
      return pendingBookings;
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Widget _buildBookingList() {
    final farmerId =
        Provider.of<DataFarmers>(context, listen: false).datauser.id;

    return FutureBuilder<List<BookingResponse>>(
      future: fetchPendingBookings(farmerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('ยังไม่มีคำขอการจอง'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ชื่อ : ${booking.farmerName}",
                        style: const TextStyle(fontSize: 16)),
                    Text(
                      "วันที่ : ${DateFormat('dd/MM/yyyy').format(booking.scheduleDate)}   เวลา : ${booking.scheduleTime}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "จองกับ : ${booking.vetName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "พ่อพันธุ์ : ${booking.bullname} ${booking.bullbreed} จำนวน ${booking.dose} โดส",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text("เพิ่มเติม : ${booking.detailBull}",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
