import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class Seachpage extends StatefulWidget {
  const Seachpage({super.key});

  @override
  State<Seachpage> createState() => _SeachpageState();
}

class _SeachpageState extends State<Seachpage> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: const InputDecoration(
                hintText: 'พิมพ์พ่อพันธุ์ที่ต้องการค้นหา',
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: Icon(Icons.search, color: Colors.grey)),
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดสีของไอคอนใน AppBar ให้เป็นสีขาว
        ),
      ),
      body: SingleChildScrollView(
          child: //Text('ค้นหา: $_searchText'),
              Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: FilledButton(
                        onPressed: chooseall,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[350]!),
                        ),
                        child: Text(
                          'ทั้งหมด',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: FilledButton(
                        onPressed: chooseall,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[350]!),
                        ),
                        child: Text(
                          'จังหวัด',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: FilledButton(
                        onPressed: chooseall,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[350]!),
                        ),
                        child: Text(
                          'อำเภอ',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: FilledButton(
                        onPressed: chooseall,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[350]!),
                        ),
                        child: Text(
                          'ตำบล',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 15, bottom: 10),
                child: Text('ผลการค้นหา : ',
                    style: GoogleFonts.notoSansThai(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(
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
                              fontSize: 14,
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
        ],
      )),
    );
  }

  void chooseall() {}

  void seedoctor() {}
}
