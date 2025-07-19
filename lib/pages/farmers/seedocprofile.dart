import 'package:cow_booking/pages/farmers/bookingpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class Seedocprofilepage extends StatefulWidget {
  const Seedocprofilepage({super.key});

  @override
  State<Seedocprofilepage> createState() => _SeedocprofilepageState();
}

class _SeedocprofilepageState extends State<Seedocprofilepage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // จำนวนแท็บ
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen[700],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/pin.jpg'),
                ),
              ),
            ),
            Text('หมอธนัท',
                style: GoogleFonts.notoSansThai(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text('ต.แวง อ.สว่างแดนดิน จ.สกลนคร',
                style: GoogleFonts.notoSansThai(
                    fontSize: 18, color: Colors.black)),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('มีน้ำเชื้อในสต๊อก 20 โดส',
                      style: GoogleFonts.notoSansThai(fontSize: 12)),
                  Text('ประสบการณ์การผสม 52 ครั้ง',
                      style: GoogleFonts.notoSansThai(fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TabBar(
              labelColor: Colors.green[600],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: [
                const Tab(text: 'สต๊อก'),
                const Tab(text: 'ตารางงาน'),
                const Tab(text: 'ที่อยู่'),
              ],
            ),

            //TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  _stockTab(), // "สต๊อก"
                  _workSchedule(), // "ตารางงาน"
                  _mapAddress(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _stockTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.library_add_check),
          title: const Text('ซุปเปอร์แมน'),
          subtitle: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('บราห์มัน'),
              Text('น้ำเชื้อจาก บุญน้อมฟาร์ม', style: TextStyle(fontSize: 12),),
            ],
          ),
          // trailing: const Icon(Icons.arrow_forward_ios,),
          // onTap: () {},
          trailing: const Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text('จอง', style: TextStyle(color: Colors.red)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Bookingpage()),
            );
          },
        ),
      ],
    );
  }

  Widget _workSchedule() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          locale: 'th_TH', // ภาษาไทย
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapAddress() {
    return const SingleChildScrollView(
      child: Text('map'),
    );
  }
}
