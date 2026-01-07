import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/detailQueue.dart';
import 'package:cow_booking/pages/Animal_husbandry/docprofile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Homepagedoc extends StatefulWidget {
  @override
  State<Homepagedoc> createState() => _HomepagedocState();
}

class _HomepagedocState extends State<Homepagedoc> {
  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // คำขอการจอง / ตอบรับแล้ว / ปฏิเสธ
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back, color: Colors.white),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
          automaticallyImplyLeading: false,
          title: const Text(
            "หน้าหลัก",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          //centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VetProfilePage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Consumer<DataVetExpert>(
                  builder: (context, dataVet, _) {
                    final imageUrl = dataVet.datauser.profileImage;
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: (imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : const NetworkImage(
                              'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "คิวผสมเทียมของคุณ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const TabBar(
              indicatorColor: Colors.green,
              labelColor: Color.fromARGB(255, 25, 71, 37),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "คำขอการจอง"),
                Tab(text: "ตอบรับแล้ว"),
                Tab(text: "ปฏิเสธ"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingList(),
                  _buildBookingAcceptList(),
                  _buildBookingCanceltList(),
                  //const Center(child: Text("ยังไม่มีรายการตอบรับแล้ว")),
                  //const Center(child: Text("ยังไม่มีรายการที่ปฏิเสธ")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<BookingResponse>> fetchPendingBookings(int vetId) async {
    final response = await http.get(
      Uri.parse('$apiEndpoint/queuebook/bookings/vet/$vetId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // กรองเฉพาะ status = 'pending'
      final pendingBookings = data
          .map((e) => BookingResponse.fromJson(e))
          .where((b) => b.status == 'pending')
          .toList();
      return pendingBookings;
    } else {
      throw Exception('Failed to load bookings');
    }
  }

    Future<List<BookingResponse>> fetchAcceptedBookings(int vetId) async {
    final response = await http.get(
      Uri.parse('$apiEndpoint/queuebook/bookings/vet/$vetId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => BookingResponse.fromJson(e))
          .where((b) => b.status == 'accepted')
          .toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }


  Future<List<BookingResponse>> fetchCancelBookings(int vetId) async {
    final response = await http.get(
      Uri.parse('$apiEndpoint/queuebook/bookings/vet/$vetId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // กรองเฉพาะ status = 'pending'
      final pendingBookings = data
          .map((e) => BookingResponse.fromJson(e))
          .where((b) => b.status == 'rejected')
          .toList();
      return pendingBookings;
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  void detailqueue(BookingResponse booking) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailqueuePage(booking: booking),
    ),
  );
}


  Widget _buildBookingList() {
    final vetId =
        Provider.of<DataVetExpert>(context, listen: false).datauser.id;

    return FutureBuilder<List<BookingResponse>>(
      future: fetchPendingBookings(vetId),
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
                        style: TextStyle(fontSize: 16)),
                    Text(
                      "วันที่ : ${DateFormat('dd/MM/yyyy').format(booking.scheduleDate)}   เวลา : ${booking.scheduleTime}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "พ่อพันธุ์ : ${booking.bullname} ${booking.bullbreed} จำนวน ${booking.dose} โดส",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("เพิ่มเติม : ${booking.detailBull}",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        //onPressed: detailqueue,
                        onPressed: () => detailqueue(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                        ),
                        child: const Text("รายละเอียด",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingAcceptList() {
    final vetId =
        Provider.of<DataVetExpert>(context, listen: false).datauser.id;

    return FutureBuilder<List<BookingResponse>>(
      future: fetchAcceptedBookings(vetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('ยังไม่มีรายการที่ตอบรับแล้ว'));
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
                        style: TextStyle(fontSize: 16)),
                    Text(
                      "วันที่ : ${DateFormat('dd/MM/yyyy').format(booking.scheduleDate)}   เวลา : ${booking.scheduleTime}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "พ่อพันธุ์ : ${booking.bullname} ${booking.bullbreed} จำนวน ${booking.dose} โดส",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("เพิ่มเติม : ${booking.detailBull}",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                      onPressed: () => detailqueue(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: const Text(
                        "รายละเอียด",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildBookingCanceltList() {
    final vetId =
        Provider.of<DataVetExpert>(context, listen: false).datauser.id;

    return FutureBuilder<List<BookingResponse>>(
      future: fetchCancelBookings(vetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(child: Text('ยังไม่มีรายการที่ตอบรับแล้ว'));
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
                        style: TextStyle(fontSize: 16)),
                    Text(
                      "วันที่ : ${DateFormat('dd/MM/yyyy').format(booking.scheduleDate)}   เวลา : ${booking.scheduleTime}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "พ่อพันธุ์ : ${booking.bullname} ${booking.bullbreed} จำนวน ${booking.dose} โดส",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("เพิ่มเติม : ${booking.detailBull}",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                      onPressed: () => detailqueue(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: const Text(
                        "รายละเอียด",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    ),
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
