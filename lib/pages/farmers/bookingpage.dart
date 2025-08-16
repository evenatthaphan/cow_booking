import 'package:cow_booking/pages/farmers/acceptbooking.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              'เลือกวันจองคิว',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'เลือกวันและเวลาที่ต้องการใช้บริการ',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30, left: 16),
              child: Row(
                children: [
                  Text('ปฏิทินงานหมอนัท : ',
                      style: TextStyle(
                        fontSize: 14,
                      ))
                ],
              ),
            ),
            Padding(
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
            SizedBox(
              width: 300,
              child: Card.outlined(
                child: Column(
                  children: [
                    Text(
                      'รายละเอียดวันในการใช้บริการ', style: TextStyle(color: Colors.lightGreen[900]),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 12),
                              SizedBox(width: 10,),
                              Text(
                                'มีคิวแล้ว ไม่สามารถให้บริการได้',style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              SizedBox(width: 10,),
                              Text(
                                'คิวว่าง สามารถให้บริการได้',style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),Row(
                            children: [
                              Icon(Icons.circle, color: Colors.grey, size: 12),
                              SizedBox(width: 10,),
                              Text(
                                'ไม่ใด้ให้บริการ',style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 30),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: FilledButton(
                      onPressed: choose,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green[900]!),
                      ),
                      child: const Text(
                        'เลือก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ),
              ),
          ],
        ),
      )),
    );
  }

  void choose() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Acceptbookingpage(),
        ));
  }
}
