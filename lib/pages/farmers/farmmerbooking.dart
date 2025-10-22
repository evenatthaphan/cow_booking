import 'package:flutter/material.dart';

class Farmmerbookingpage extends StatefulWidget {
  const Farmmerbookingpage({super.key});

  @override
  State<Farmmerbookingpage> createState() => _FarmmerbookingpageState();
}

class _FarmmerbookingpageState extends State<Farmmerbookingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'คิวของฉัน',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดสีของไอคอนใน AppBar ให้เป็นสีขาว
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [Text("123")],
        ),
      ),
    );
  }
}