import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลส่วนตัว',
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
              const SizedBox(width: 16),
              TextButton(
                  onPressed: () {},
                  child: Text('เปลี่ยนรูปภาพโปรไฟล์',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 16,
                          color: Colors.green[900]))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 30),
            child: Text('ชื่อผู้ใช้ * ',
                style: GoogleFonts.notoSansThai(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 14,
                    color:  Colors.grey)),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30),
            child: Text('เบอร์โทรศัพท์ * ',
                style: GoogleFonts.notoSansThai(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 14,
                    color:  Colors.grey)),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30),
            child: Text('อีเมลล์',
                style: GoogleFonts.notoSansThai(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 14,
                    color:  Colors.grey)),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green[900]!),
                    shape: MaterialStateProperty.all<CircleBorder>(
                      const CircleBorder(), // ทำให้ปุ่มเป็นวงกลม
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(20), // กำหนดขนาดของปุ่ม
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on, // ชื่อไอคอน
                    color: Colors.white, // สีของไอคอน
                    size: 20, // ขนาดของไอคอน
                  ),
                ),
                Text('   คลิกเพื่อแก้ไขตำแหน่งที่อยู่ * ',
                    style: GoogleFonts.notoSansThai(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 14,
                        color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2, color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: FilledButton(
                        onPressed: saveeidt,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green[900]!),
                        ),
                        child: Text(
                          'บันทึก',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void saveeidt() {}
}
