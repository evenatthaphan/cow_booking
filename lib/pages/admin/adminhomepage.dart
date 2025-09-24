import 'package:flutter/material.dart';

class HompageAdmin extends StatefulWidget {
  const HompageAdmin({super.key});

  @override
  State<HompageAdmin> createState() => _HompageAdminState();
}

class _HompageAdminState extends State<HompageAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: const Text('หน้าหลัก',
            style: TextStyle(
              fontSize: 22,
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