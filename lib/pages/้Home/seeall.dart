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
                width: 500,
                height: 130,
                child: Card(
                  color: Color.fromARGB(255, 217, 253, 204),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: SizedBox(
                            width: 130,
                            child: Image.asset(
                              'assets/images/supperman.jpg',
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 16,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('พันธุ์ : บราห์มัน',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('ฟาร์ม : บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('จำนวนการผสม : 25 ครั้ง',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('สำเร็จ : 20 ครั้ง',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            SizedBox(
                              width: 175,
                              height: 20,
                              child: FilledButton(
                                  onPressed: seedoctor,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.green[900]!),
                                  ),
                                  child: Text(
                                    'คลิคเพื่อดูสัตวบาล',
                                    style: GoogleFonts.notoSansThai(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 500,
                height: 130,
                child: Card(
                  color: Color.fromARGB(255, 217, 253, 204),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: SizedBox(
                            width: 130,
                            child: Image.asset(
                              'assets/images/supperman.jpg',
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 16,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('พันธุ์ : บราห์มัน',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('ฟาร์ม : บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('จำนวนการผสม : 25 ครั้ง',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            Text('สำเร็จ : 20 ครั้ง',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                            
                          ],
                        ),
                      ),
                      // FilledButton(
                      //             onPressed: seedoctor,
                      //             style: ButtonStyle(
                      //               backgroundColor:
                      //                   MaterialStateProperty.all<Color>(
                      //                       Colors.green[900]!),
                      //             ), child: IconButton(onPressed: seedetail, icon: ),),
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

  void seedetail() {
  }
}
