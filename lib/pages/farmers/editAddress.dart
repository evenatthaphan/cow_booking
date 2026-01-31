import 'package:flutter/material.dart';

class EditaddressPage extends StatefulWidget {
  const EditaddressPage({super.key});

  @override
  State<EditaddressPage> createState() => _EditaddressPageState();
}

class _EditaddressPageState extends State<EditaddressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: const Text('แก้ไขที่อยู่',
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