import 'package:cow_booking/pages/Animal_husbandry/home_page_doc.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/admin/admin_dashbord_page.dart';
import 'package:cow_booking/pages/choose_login.dart';
import 'package:cow_booking/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized(); // async ก่อน runApp
  // await fetchSomething();
 
  await dotenv.load(fileName: ".env");  // โหลด .env
  // set mapbox token
  MapboxOptions.setAccessToken(
    dotenv.env['MAPBOX_ACCESS_TOKEN']!,
  );
  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataFarmers()),
        ChangeNotifierProvider(create: (_) => DataVetExpert()),
        ChangeNotifierProvider(create: (_) => DataBull()),
        ChangeNotifierProvider(create: (_) => DataAdmin()),
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

  // Future<Widget> _getStartPage(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //   final userType = prefs.getString('userType');
  //   final userId = prefs.getInt('userId');

  //   if (isLoggedIn && userType != null && userId != null) {
  //     try {
  //       if (userType == 'farmer') {
  //         await context
  //             .read<DataFarmers>()
  //             .fetchFarmerById(userId);

  //         return Homepage();
  //       }

  //       if (userType == 'vet') {
  //         await context
  //             .read<DataVetExpert>()
  //             .fetchVetById(userId);

  //         return Homepagedoc();
  //       }
  //     } catch (e) {
  //       // session / token หมดอายุ
  //       await prefs.clear();
  //     }
  //   }

  //   return const Loginpage();
  // }

  Future<Widget> _getStartPage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType');
    final userId = prefs.getInt('userId');

    if (isLoggedIn && userType != null && userId != null) {
      try {
        if (userType == 'farmer') {
          await context.read<DataFarmers>().fetchFarmerById(userId);
          return Homepage();
        }

        if (userType == 'vet') {
          await context.read<DataVetExpert>().fetchVetById(userId);
          return Homepagedoc();
        }

        // เพิ่มเช็กของ Admin เข้าไปด้วยเพื่อไม่ให้หลุดหน้าล็อกอิน
        if (userType == 'admin') {
          // สมมติว่าใน DataAdmin มีฟังก์ชันดึงข้อมูลตาม ID เช่นกัน
          // await context.read<DataAdmin>().fetchAdminById(userId); 
          return const AdminDashboardPage(); // หรือหน้า Dashboard ของคุณ
        }

      } catch (e) {
        print("เกิดข้อผิดพลาดในการดึงข้อมูล (อาจเพราะเซิร์ฟเวอร์ Render กำลังตื่น): $e");
        

        // เพื่อป้องกันไม่ให้ข้อมูลล็อกอินหายเวลาเซิร์ฟเวอร์ Render ตอบกลับช้า
        // ทางเลือก: หากดึงข้อมูลไม่สำเร็จเนื่องจากเซิร์ฟเวอร์หลับ แต่เครื่องมีข้อมูลอยู่แล้ว 
        // ก็ปล่อยให้เข้าหน้า Home ไปก่อนได้เลย
        if (userType == 'farmer') return Homepage();
        if (userType == 'vet') return Homepagedoc();
        if (userType == 'admin') return const AdminDashboardPage();
      }
    }

    return  Homepage(); //
  }

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(context),
      builder: (context, snapshot) {
        // waittng SharedPreferences load
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
             localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
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
          return GetMaterialApp(
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
        return const GetMaterialApp(
          home: Scaffold(
            body: Center(child: Text('เกิดข้อผิดพลาดในการโหลดหน้าเริ่มต้น')),
          ),
        );
      },
    );
  }
}
