import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerRegister extends StatefulWidget {
  const FarmerRegister({super.key});

  @override
  State<FarmerRegister> createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ลงทะเบียนเกษตรกร',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('กรุณากรอกข้อมูลเพื่อลงทะเบียนสมาชิก และเข้าใช้งานระบบ',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.green)),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('ชื่อผู้ใช้',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Colors.grey), // สีกรอบปกติ
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('เบอร์โทรศัพท์',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Colors.grey), // สีกรอบปกติ
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('อีเมลล์',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      // Text(' *',
                      //     style: GoogleFonts.notoSansThai(
                      //         textStyle:
                      //             Theme.of(context).textTheme.displayLarge,
                      //         fontSize: 14,
                      //         color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Colors.grey), // สีกรอบปกติ
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green[900]!),
                          shape: MaterialStateProperty.all<CircleBorder>(
                            CircleBorder(), // ทำให้ปุ่มเป็นวงกลม
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(20), // กำหนดขนาดของปุ่ม
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on, // ชื่อไอคอน
                          color: Colors.white, // สีของไอคอน
                          size: 20, // ขนาดของไอคอน
                        ),
                      ),
                      Text('   คลิกเพื่อเลือกตำแหน่งที่อยู่',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Colors.grey), // สีกรอบปกติ
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 30),
              child: Row(
                children: [
                  Text('รหัสผ่าน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey)),
                  Text(' *',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.red))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 30),
              child: Row(
                children: [
                  Text('ยืนยันรหัสผ่าน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey)),
                  Text(' *',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.red))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: OutlinedButton(
                  onPressed: backtologin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.green, // สีของเส้นขอบ
                      width: 2, // ความหนาของเส้นขอบ
                    ),
                  ),
                  child: Text(
                    'ลงทะเบียน',
                    style: GoogleFonts.notoSansThai(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void backtologin() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
