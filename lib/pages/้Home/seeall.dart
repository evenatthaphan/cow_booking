import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/pages/%E0%B9%89Home/seach.dart';

class Allmramanpage extends StatefulWidget {
  const Allmramanpage({super.key});

  @override
  State<Allmramanpage> createState() => _AllmramanpageState();
}

class _AllmramanpageState extends State<Allmramanpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ดูทั้งหมด',
          style: GoogleFonts.notoSansThai(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดสีของไอคอนใน AppBar ให้เป็นสีขาว
        ),
        actions: [
          // ปุ่มค้นหา
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: seach,
          ),
          // รูปโปรไฟล์
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                  'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
            width: 400,
            height: 130,
            child: Card.outlined(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // ขอบโค้งของ Card
                side: const BorderSide(
                  color: Colors.black, // สีขอบ
                  width: 1, // ความหนาของขอบ
                ),
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: SizedBox(
                      width: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/supperman.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ซุปเปอร์แมน',
                            style: GoogleFonts.notoSansThai(
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('บุญน้อมฟาร์ม',
                            style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.black,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Resrve calf champion red bull',
                            style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 12,
                              color: Colors.black,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 40,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
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
                                              fontSize: 10,
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
                                              fontSize: 10,
                                              color: Colors.black)),
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                // SizedBox(
                                //     height: 30,
                                //     child: OutlinedButton(
                                //       onPressed: () {},
                                //       child: Text('สีแดง',
                                //           style: GoogleFonts.notoSansThai(
                                //               textStyle: Theme.of(context)
                                //                   .textTheme
                                //                   .displayLarge,
                                //               fontSize: 10,
                                //               color: Colors.black)),
                                //     )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
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

  void seach() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Seachpage(),
        ));
  }

  void seedoctor() {}

  void seedetail() {}
}
