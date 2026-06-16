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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//Global key สำหรับแสดง SnackBar จากทุกหน้า
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  // ✅ Foreground handler — แสดง SnackBar เมื่อ app เปิดอยู่
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

    debugPrint('📩 Foreground: $title');

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              body,
              style: GoogleFonts.notoSansThai(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  });

  // ✅ Notification tap handler — เมื่อผู้ใช้แตะการแจ้งเตือน (app still open)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📲 Notification tapped: ${message.notification?.title}');
    // คุณสามารถนำทางไปหน้าที่ต้องการตามข้อมูลในการแจ้งเตือน
  });

  // ✅ Terminated state handler — เมื่อ app เปิดจากการแจ้งเตือนในสถานะปิด
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint(
        '📲 App opened from notification: ${initialMessage.notification?.title}');
    // จัดการการนำทาง
  }

  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

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
        if (userType == 'admin') {
          return const AdminDashboardPage();
        }
      } catch (e) {
        print(
            "เกิดข้อผิดพลาดในการดึงข้อมูล (อาจเพราะเซิร์ฟเวอร์ Render กำลังตื่น): $e");
        if (userType == 'farmer') return Homepage();
        if (userType == 'vet') return Homepagedoc();
        if (userType == 'admin') return const AdminDashboardPage();
      }
    }

    return Homepage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldMessengerKey, // ✅
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(color: Colors.green[900]),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return GetMaterialApp(
            title: 'App Demo',
            scaffoldMessengerKey: scaffoldMessengerKey, // ✅
            debugShowCheckedModeBanner: false,
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
            home: snapshot.data,
          );
        }

        return GetMaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey, // ✅
          home: const Scaffold(
            body: Center(child: Text('เกิดข้อผิดพลาดในการโหลดหน้าเริ่มต้น')),
          ),
        );
      },
    );
  }
}
