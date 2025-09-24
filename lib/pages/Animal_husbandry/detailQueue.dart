import 'package:flutter/material.dart';

class DetailqueuePage extends StatefulWidget {
  const DetailqueuePage({super.key});

  @override
  State<DetailqueuePage> createState() => __DetailqueuePageState();
}

class __DetailqueuePageState extends State<DetailqueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "รายละเอียดคิว",
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 350,
              height: 400,
              child: Card.outlined(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // ขอบโค้ง
                ),
                clipBehavior: Clip.antiAlias, // บังคับให้ child (Image) โค้งตาม
                child: Image.asset(
                  "assets/images/map.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 350,
              height: 200,
              child: Card.filled(
                  color: const Color(0xFFF8F1E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // ขอบโค้ง
                  ),
                  clipBehavior:
                      Clip.antiAlias, // บังคับให้ child (Image) โค้งตาม
                  child: const Padding(
                    padding: EdgeInsets.all(10),
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
                          SizedBox(height: 10),
                        ]),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
