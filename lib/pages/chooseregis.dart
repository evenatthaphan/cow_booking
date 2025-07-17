import 'package:cow_booking/pages/Animal_husbandry/doctorregis.dart';
import 'package:cow_booking/pages/farmers/farmerregis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chooseregis extends StatefulWidget {
  const Chooseregis({super.key});

  @override
  State<Chooseregis> createState() => _ChooseregisState();
}

class _ChooseregisState extends State<Chooseregis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100, left: 30),
                child: Row(
                  children: [
                    Text(
                      'ลงทะเบียน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 30),
                child: Row(
                  children: [
                    Text('กรุณาเลือกประเภทผู้ใช้ที่ท่านต้องการลงทะเบียน',
                        style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black)),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80, left: 50, right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 70,
                          child: FilledButton(
                              onPressed: farmerregis,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.lightGreen[700]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(
                                    Icons.edit_document, // ชื่อไอคอน
                                    color: Colors.white, // สีของไอคอน
                                    size: 40, // ขนาดของไอคอน
                                  ),
                                  const SizedBox(
                                      width: 5), // ระยะห่างระหว่างไอคอนและข้อความ
                                  Text(
                                    'เกษตรกร',
                                    style: GoogleFonts.notoSansThai(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 70,
                          child: FilledButton(
                              onPressed: doctorregis,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.greenAccent[700]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'สัตวบาล',
                                    style: GoogleFonts.notoSansThai(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 5), // ระยะห่างระหว่างไอคอนและข้อความ
                                  const Icon(
                                    Icons.edit_document, // ชื่อไอคอน
                                    color: Colors.white, // สีของไอคอน
                                    size: 40, // ขนาดของไอคอน
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 80, left: 90, right: 90),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('คุณมีบัญชีอยู่แล้ว? ',
                            style: GoogleFonts.notoSansThai(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                        Column(
                          children: [
                            Text('คลิก',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      TextDecoration.underline, // ขีดเส้นใต้
                                  decorationColor: Colors.green, // สีของเส้นใต้
                                  decorationThickness: 2, // ความหนาของเส้นใต้
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void farmerregis() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FarmerRegister(),
        ));
  }

  void doctorregis() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorRegis(),
        ));
  }
}
