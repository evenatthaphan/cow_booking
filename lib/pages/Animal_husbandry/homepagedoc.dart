import 'package:cow_booking/pages/Animal_husbandry/detailQueue.dart';
import 'package:flutter/material.dart';

class Homepagedoc extends StatefulWidget {
  //const Homepagedoc({super.key});
  // final String userId;
  // const Homepagedoc ({super.key, required this.userId});

  @override
  State<Homepagedoc> createState() => _HomepagedocState();
}

class _HomepagedocState extends State<Homepagedoc> {
  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF8F1E8),
  //     appBar: AppBar(
  //       title: const Text('หน้าหลัก',
  //           style: TextStyle(
  //             fontSize: 22,
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //           )),
  //       centerTitle: true,
  //       backgroundColor: Colors.lightGreen[700],
  //       iconTheme: const IconThemeData(color: Colors.white),
  //     ),
  //     body: Center(
  //       //child: Text("Welcome Vet, ID: $userId"),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // คำขอการจอง / ตอบรับแล้ว / ปฏิเสธ
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
            "หน้าหลัก",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          //centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle, color: Colors.white),
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
                  const Center(child: Text("ยังไม่มีรายการตอบรับแล้ว")),
                  const Center(child: Text("ยังไม่มีรายการที่ถูกปฏิเสธ")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 2, // ตัวอย่าง 2 รายการ
      itemBuilder: (context, index) {
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
                Text("ชื่อ : นายสิริ พรศรี",
                    style: TextStyle(fontSize: 16)),
                Text("วันที่ : 12 กันยายน 2025   เวลา : 10.30",
                    style: TextStyle(fontSize: 16)),
                Text("เพิ่มเติม : แม้วัวอายุ 5 ปี",
                    style: TextStyle(fontSize: 16)),
                Text("พ่อพันธุ์ : ซุปเปอร์แมน บราห์มัน   จำนวน : 1 โดส",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: detailqueue,
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
  }

  void detailqueue() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailqueuePage(),
        ));
  }
}
