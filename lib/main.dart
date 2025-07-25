import 'package:cow_booking/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'), 
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // กำหนดพื้นหลังสีขาวเป็นค่าเริ่มต้น
            textTheme: GoogleFonts.notoSansThaiTextTheme(), 
            primarySwatch: Colors.green,
      ),
      home: const Loginpage(),
    );
  }
}
