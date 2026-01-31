import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/docprofile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailqueuePage extends StatefulWidget {
  final BookingResponse booking;

  const DetailqueuePage({
  super.key,
  required this.booking,
});


  //const DetailqueuePage({super.key});

  @override
  State<DetailqueuePage> createState() => __DetailqueuePageState();
}

class __DetailqueuePageState extends State<DetailqueuePage> {

  @override
  Widget build(BuildContext context) {

    
  final booking = widget.booking;

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
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.account_circle, color: Colors.white),
        //   ),
        // ],
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
                  child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ชื่อ : ${booking.farmersName}",
                          style: const TextStyle(fontSize: 16)),
                      Text(
                        "วันที่ : ${DateFormat('dd/MM/yyyy').format(booking.scheduleDate)}   เวลา : ${booking.scheduleTime}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text("เพิ่มเติม : ${booking.bookingsDetailBull}",
                          style: const TextStyle(fontSize: 16)),
                      Text(
                        "พ่อพันธุ์ : ${booking.bullsName} ${booking.bullsBreed}   จำนวน : ${booking.bookingsDose} โดส",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

            ),
            ),
          ],
        ),
      ),
    );
  }
}
