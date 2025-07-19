import 'package:flutter/material.dart';

class Bookingpage extends StatefulWidget {
  const Bookingpage({super.key});

  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: const Text('จองคิว',
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