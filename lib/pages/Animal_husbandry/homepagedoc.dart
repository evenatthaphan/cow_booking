import 'package:flutter/material.dart';

class Homepagedoc extends StatefulWidget {
  //const Homepagedoc({super.key});
  // final String userId;
  // const Homepagedoc ({super.key, required this.userId});

  @override
  State<Homepagedoc> createState() => _HomepagedocState();
}

class _HomepagedocState extends State<Homepagedoc> {
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
      body: Center(
        //child: Text("Welcome Vet, ID: $userId"),
      ),
    );
  }
}