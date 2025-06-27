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
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 40,
                  child: FilledButton(
                      onPressed: chooseall,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green[900]!),
                      ),
                      child: Text(
                        'ทั้งหมด',
                        style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.white,
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
                            Colors.green[400]!),
                      ),
                      child: Text(
                        'จังหวัด',
                        style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.white,
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
                            Colors.green[400]!),
                      ),
                      child: Text(
                        'อำเภอ',
                        style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )),
                ),
                const SizedBox(
                  width: 5,
                ),
                // SizedBox(
                //   width: 100,
                //   height: 40,
                //   child: FilledButton(
                //       onPressed: chooseall,
                //       style: ButtonStyle(
                //         backgroundColor: MaterialStateProperty.all<Color>(
                //             Colors.green[900]!),
                //       ),
                //       child: Text(
                //         'ตำบล',
                //         style: GoogleFonts.notoSansThai(
                //           textStyle: Theme.of(context).textTheme.displayLarge,
                //           fontSize: 14,
                //           color: Colors.white,
                //         ),
                //       )),
                // ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
            height: 1.0,
            color: const Color.fromARGB(255, 35, 121, 41),
          ),
          SizedBox(
            width: 500,
            height: 130,
            child: Card(
              color: const Color.fromARGB(255, 217, 253, 204),
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
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge,
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
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
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
        ],
      )),
    );
  }

  void chooseall() {}

  void seedoctor() {}
}
