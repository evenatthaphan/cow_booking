import 'package:cow_booking/pages/Animal_husbandry/home_page_doc.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/choose_login.dart';
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


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType');
    final userId = prefs.getInt('userId');

    if (isLoggedIn && userType != null && userId != null) {
      try {
        if (userType == 'farmer') {
          await context
              .read<DataFarmers>()
              .fetchFarmerById(userId);

          return Homepage();
        }

        if (userType == 'vet') {
          await context
              .read<DataVetExpert>()
              .fetchVetById(userId);

          return Homepagedoc();
        }
      } catch (e) {
        // session / token หมดอายุ
        await prefs.clear();
      }
    }

    return const Loginpage();
  }

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(context),
      builder: (context, snapshot) {
        // waittng SharedPreferences load
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

        // if download sucess
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
