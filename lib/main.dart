import 'package:cow_booking/pages/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo',
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // กำหนดพื้นหลังสีขาวเป็นค่าเริ่มต้น
      ),
      home: const Loginpage(),
    );
  }
}
