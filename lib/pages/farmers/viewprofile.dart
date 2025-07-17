import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewprofile extends StatefulWidget {
  const Viewprofile({super.key});

  @override
  State<Viewprofile> createState() => _ViewprofileState();
}

class _ViewprofileState extends State<Viewprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text('แก้ไขโปรไฟล์',
            style: GoogleFonts.notoSansThai(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}