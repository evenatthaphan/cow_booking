import 'package:cow_booking/pages/farmers/seedocprofile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cowdetailpage extends StatefulWidget {
  const Cowdetailpage({super.key});

  @override
  State<Cowdetailpage> createState() => _CowdetailpageState();
}

class _CowdetailpageState extends State<Cowdetailpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      backgroundColor: Colors.lightGreen[700],
      body: SafeArea(
        child: Column(
          children: [
            // ภาพบน
            Stack(
              children: [
                Image.asset(
                  'assets/images/imagecow.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 350,
                ),
                Positioned(
                  top: 20,
                  left: 16,
                  child: Positioned(
                    top: 20,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 10,
                  left: 14,
                  child: Text(
                    'ซุปเปอร์แมน',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(142, 238, 229, 229),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'บราห์มัน',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'บุญน้อมฟาร์ม',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.white),
                            label: const Text(
                              "ชอบ",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'ชนะรางวัล Resrve calf champion red bull',
                        style: TextStyle(color: Colors.black),
                      ),
                      const Row(
                        children: [
                          Text(
                            'เคยผสมมาแล้ว 20 ครั้ง',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'ผสมสำเร็จ 18 ครั้ง',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                              height: 30,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text('โหนกใหญ่',
                                    style: GoogleFonts.notoSansThai(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 14,
                                        color: Colors.black)),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                              height: 30,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text('ขนสั้น',
                                    style: GoogleFonts.notoSansThai(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 14,
                                        color: Colors.black)),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                              height: 30,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text('สีแดง',
                                    style: GoogleFonts.notoSansThai(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 14,
                                        color: Colors.black)),
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          height: 2.0,
                          color: const Color.fromARGB(255, 35, 121, 41),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('สัตวบาลที่มีน้ำเชื้อ',
                                style: GoogleFonts.notoSansThai(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: seedocall,
                                child: Text('ดูทั้งหมด',
                                    style: GoogleFonts.notoSansThai(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[400]))),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 400,
                        child: Card.outlined(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // ขอบโค้งของ Card
                            side: const BorderSide(
                              color: Colors.black, // สีขอบ
                              width: 1, // ความหนาของขอบ
                            ),
                          ),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16, right: 5),
                                child: SizedBox(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        AssetImage('assets/images/pin.jpg'),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('หมอธนัท',
                                        style: GoogleFonts.notoSansThai(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .displayLarge,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('เคยผสมมาแล้ว 54 ครั้ง',
                                        style: GoogleFonts.notoSansThai(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: 14,
                                          color: Colors.black,
                                        )),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('ต.แวง อ.สว่างแดนดิน จ.สกลนคร',
                                        style: GoogleFonts.notoSansThai(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: 14,
                                          color: Colors.black,
                                        )),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: seedocprofile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize:
                                      Size(40, 40), 
                                  padding:
                                      EdgeInsets.zero, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.navigate_next,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void seedocall() {}

  void seedocprofile() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Seedocprofilepage(),
        ));
  }
}
