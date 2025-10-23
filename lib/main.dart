import 'package:cow_booking/pages/Animal_husbandry/homepagedoc.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/chooselogin.dart';
import 'package:cow_booking/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized(); // async ก่อน runApp
  // await fetchSomething();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataFarmers()),
        ChangeNotifierProvider(create: (_) => DataVetExpert()),
        ChangeNotifierProvider(create: (_) => DataBull()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> testAsync() {
  return Future.delayed(const Duration(seconds: 2), () => print("BBB"));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<Widget> _getStartPage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final userType = prefs.getString('userType');

//     if (isLoggedIn && userType != null) {
//       if (userType == 'farmer') {
//         return Homepage();
//       } else if (userType == 'vet') {
//         return Homepagedoc();
//       }
//     }
//     return const ChooseLogin();
//   }

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'App Demo',
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('th', 'TH'),
//         Locale('en', 'US'),
//       ],
//       theme: ThemeData(
//         scaffoldBackgroundColor:
//             Colors.white, // กำหนดพื้นหลังสีขาวเป็นค่าเริ่มต้น
//             textTheme: GoogleFonts.notoSansThaiTextTheme(),
//             primarySwatch: Colors.green,
//       ),
//       home: snapshot.data,
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType');

    if (isLoggedIn && userType != null) {
      if (userType == 'farmer') {
        return Homepage();
      } else if (userType == 'vet') {
        return Homepagedoc();
      }
    }
    return const ChooseLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        // ขณะรอ SharedPreferences โหลด
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.green[900],
                ),
              ),
            ),
          );
        }

        // ถ้าโหลดเสร็จแล้ว
        if (snapshot.hasData) {
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
              scaffoldBackgroundColor: Colors.white,
              textTheme: GoogleFonts.notoSansThaiTextTheme(),
              primarySwatch: Colors.green,
            ),
            home: snapshot.data, // 
          );
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('เกิดข้อผิดพลาดในการโหลดหน้าเริ่มต้น')),
          ),
        );
      },
    );
  }
}
