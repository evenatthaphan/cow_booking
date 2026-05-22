import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerNotificationPage extends StatefulWidget {
  const FarmerNotificationPage({super.key});

  @override
  State<FarmerNotificationPage> createState() => __FarmerNotificationPageState();
}

class __FarmerNotificationPageState extends State<FarmerNotificationPage> {

  static const _green = Color(0xFF2E7D32);

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        elevation: 0,
        backgroundColor: _green,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🐄', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cow Booking',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'การแจ้งเตือน',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1, color: Colors.white.withOpacity(0.1)),
        ),
      );
    }

    
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(),
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