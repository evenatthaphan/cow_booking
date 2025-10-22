import 'package:cow_booking/pages/farmers/farmerNavbar.dart';
import 'package:flutter/material.dart';

class FarmerNotificationPage extends StatefulWidget {
  const FarmerNotificationPage({super.key});

  @override
  State<FarmerNotificationPage> createState() => __FarmerNotificationPageState();
}

class __FarmerNotificationPageState extends State<FarmerNotificationPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การแจ้งเตือน',
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
      bottomNavigationBar: FarmerNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (value) {},
        screenSize: screenSize,
      ),
    );
  }
}