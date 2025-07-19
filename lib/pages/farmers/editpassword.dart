import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Editpasswoedpage extends StatefulWidget {
  const Editpasswoedpage({super.key});

  @override
  State<Editpasswoedpage> createState() => _EditpasswoedpageState();
}

class _EditpasswoedpageState extends State<Editpasswoedpage> {
  String _oldPass = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text('แก้ไขรหัสผ่าน',
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
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _oldPass = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'รหัสผ่านเดิม',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _oldPass = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'รหัสผ่านใหม่',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _oldPass = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'ยืนยันรหัสผ่านใหม่',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                ),
                const SizedBox(
                  height: 40,
                ),
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
          ),
        ],
      ),
    );
  }

  void saveeidt() {}
}
