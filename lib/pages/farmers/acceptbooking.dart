import 'package:flutter/material.dart';

class Acceptbookingpage extends StatefulWidget {
  const Acceptbookingpage({super.key});

  @override
  State<Acceptbookingpage> createState() => _AcceptbookingpageState();
}

class _AcceptbookingpageState extends State<Acceptbookingpage> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'ยืนยันรอบเวลาในการจองคิว',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreen[700]),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30, left: 40),
              child: Text(
                'วันที่ : ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'เวลาที่คุณสามารถเลือกใช้บริการได้ มีดังนี้ :',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.lightGreen[700]),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: Card.filled(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text('10.00 - 11.00 น.'),
                          Text('13.00 - 14.00 น.'),
                          Text('16.00 - 17.00 น.')
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
