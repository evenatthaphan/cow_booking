import 'package:cow_booking/model/response/admin_response.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/Animal_husbandry/home_page_doc.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/pages/admin/admin_change_password.dart';
import 'package:cow_booking/pages/admin/admin_dashbord_page.dart';
import 'package:cow_booking/pages/farmers/farmer_profile.dart';
import 'package:cow_booking/share/forgot_password_page.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:cow_booking/share/share_witget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_booking/config/internal_config.dart';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise_flutter.dart';

class ChooseLogin extends StatefulWidget {
  const ChooseLogin({super.key});

  @override
  State<ChooseLogin> createState() => _ChooseLoginState();
}

class _ChooseLoginState extends State<ChooseLogin> {
  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false; // ตัวแปรสำหรับเปิด/ปิดรหัสผ่าน
  String url = "";
  RecaptchaClient? _recaptchaClient; // reCAPTCHA Enterprise client

  final myWidget = MyWidget();
  final handleError = HandleError();

  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (value) {
        url = value['apiEndpoint'].toString();
      },
    ).catchError((err) {
      // myWidget.showCustomSnackbar("Message", 'Error in initState: $err');
    });
    _initRecaptcha();
  }

  // โหลด reCAPTCHA Enterprise client
  Future<void> _initRecaptcha() async {
    try {
      final siteKey = dotenv.env['RECAPTCHA_ANDROID_KEY'] ?? '';
      if (siteKey.isEmpty || siteKey == 'YOUR_RECAPTCHA_ANDROID_SITE_KEY_HERE') {
        debugPrint('⚠️ RECAPTCHA_ANDROID_KEY ยังไม่ได้ตั้งค่าใน .env');
        return;
      }
      _recaptchaClient = await Recaptcha.fetchClient(siteKey);
      debugPrint('✅ reCAPTCHA พร้อมใช้งาน');
    } catch (e) {
      debugPrint('❌ reCAPTCHA init error: $e');
    }
  }

  // ฟังก์ชันหลักที่ปุ่มเรียก — ทำ reCAPTCHA ก่อน แล้วค่อย login
  Future<void> _handleLoginSubmit() async {
    if (loginIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'กรุณากรอกชื่อผู้ใช้หรือรหัสผ่าน',
                style: GoogleFonts.notoSansThai(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ถ้า reCAPTCHA พร้อม ให้ execute ก่อน
    String? recaptchaToken;
    if (_recaptchaClient != null) {
      try {
        recaptchaToken = await _recaptchaClient!.execute(RecaptchaAction.LOGIN());
        debugPrint('✅ reCAPTCHA token: $recaptchaToken');
      } catch (e) {
        debugPrint('⚠️ reCAPTCHA execute error: $e');
        // fail-open: ถ้า reCAPTCHA error ยังให้ login ได้
      }
    }

    await loginUser(recaptchaToken: recaptchaToken);
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100, left: 30),
                child: Row(
                  children: [
                    Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 30),
                child: Row(
                  children: [
                    Text('กรุณากรอกชื่อผู้ใช้ หรืออีเมลล์ หรือเบอร์โทรศัพท์',
                        style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Text('และรหัสผ่านเพื่อเข้าสู่ระบบ',
                        style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.black)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 30),
                child: Row(
                  children: [
                    Text('ชื่อผู้ใช้ หรืออีเมลล์ หรือเบอร์โทรศัพท์',
                        style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.grey))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                child: TextField(
                  controller: loginIdController, // login ID
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Colors.grey), // สีกรอบปกติ
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2,
                          color: Colors.green[900]!), // สีกรอบเมื่อโฟกัส
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30),
                child: Row(
                  children: [
                    Text('รหัสผ่าน',
                        style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 14,
                            color: Colors.grey))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible, // ปิด/เปิดรหัสผ่าน
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Colors.green[900]!),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 100, right: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('คุณลืมรหัสผ่าน?',
                        style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        )),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'คลิก',
                            style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.green,
                              decorationThickness: 2,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: FilledButton(
                      onPressed: _handleLoginSubmit,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green[900]!),
                      ),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginUser({String? recaptchaToken}) async {
    final loginId = loginIdController.text.trim();
    final password = passwordController.text.trim();

    if (loginId.isEmpty || password.isEmpty) {
      myWidget.showCustomSnackbar('Message', 'กรุณากรอกข้อมูลให้ครบ');
      return;
    }

    final uri = Uri.parse('$apiEndpoint/together/login');

    try {
      // สร้าง body พร้อม recaptcha_token (ถ้ามี)
      final Map<String, dynamic> requestBody = {
        'loginId': loginId,
        'password': password,
        if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(requestBody),
      );
      debugPrint('Login URL: ' + uri.toString());
      debugPrint('Status: ' + res.statusCode.toString());
      debugPrint('Body: ' + res.body.toString());
      debugPrint('reCAPTCHA token sent: ${recaptchaToken != null ? 'yes' : 'no'}');

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        final role = data['role'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (role == 'farmer' && user != null) {
          final farmer = Farmers.fromJson(user);
          context.read<DataFarmers>().setDataUser(farmer);

          // SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'farmer');
          await prefs.setInt('userId', farmer.farmersId);

          await _showSuccessDialogAndNavigate(
            context,
            Homepage(),
          );
          return;
        }

        if (role == 'vet' && user != null) {
          print("VET USER DATA: $user");

          final vet = VetExpert(
            id: user['vetexperts_id'] ?? 0,
            vetExpertName: user['vetexperts_name'] ?? '',
            vetExpertPassword: user['vetexperts_hashpassword'] ?? '',
            password: user['vetexperts_password'] ?? '',
            phonenumber: user['vetexperts_phonenumber'] ?? '',
            vetExpertEmail: user['vetexperts_email'] ?? '',
            profileImage: user['vetexperts_profile_image'] ?? '',
            province: user['vetexperts_province'] ?? '',
            district: user['vetexperts_district'] ?? '',
            locality: user['vetexperts_locality'] ?? '',
            vetExpertAddress: user['vetexperts_address'] ?? '',
            vetExpertPl: user['vetexperts_license'] ?? '',
            totalSemenStock: user['total_semen_stock'] ?? 0,
          );

          print("VET ID: ${vet.id}");
          print("VET NAME: ${vet.vetExpertName}");
          print("VET IMAGE: ${vet.profileImage}");

          context.read<DataVetExpert>().setDataUser(vet);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'vet');
          await prefs.setInt('userId', vet.id);
          //await prefs.setInt('userId', vet.id);
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            debugPrint('FCM Token: $fcmToken');
            if (fcmToken != null) {
              final fcmRes = await http.post(
                Uri.parse('$apiEndpoint/vet/update-fcm-token'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'vet_id': vet.id,
                  'fcm_token': fcmToken,
                }),
              );
              debugPrint('FCM update: ${fcmRes.statusCode} ${fcmRes.body}');
            }
          } catch (e) {
            debugPrint('FCM error: $e');
          }

          await _showSuccessDialogAndNavigate(context, Homepagedoc());

          return;
        }

        if (role == 'admin' && user != null) {
          final admin = AdminResponse.fromJson(user);
          context.read<DataAdmin>().setDataUser(admin);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'admin');
          await prefs.setInt('userId', admin.adminsId);

          // บังคับเปลี่ยนรหัสถ้า must_change_password == 1
          if (admin.mustChangePassword == 1) {
            await _showSuccessDialogAndNavigate(
                context, AdminChangePasswordPage());
          } else {
            await _showSuccessDialogAndNavigate(context, AdminDashboardPage());
          }
          return;
        }

        // not role/user
        _showErrorDialog(context, "รูปแบบข้อมูลไม่ถูกต้อง");
      } else if (res.statusCode == 401) {
        // Username/Password wrong
        _showErrorDialog(context, "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง");
      } else {
        // handleError.handleError(res);
        String errorMessage = "เกิดข้อผิดพลาด";

        try {
          final data = jsonDecode(res.body);
          errorMessage = data['error'] ?? data['message'] ?? errorMessage;
        } catch (_) {}

        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      debugPrint('Login error: ' + e.toString());
      myWidget.showCustomSnackbar('Message', 'เกิดข้อผิดพลาดระหว่างล็อกอิน $e');
    }
  }

  Future<void> _showSuccessDialogAndNavigate(
    BuildContext context,
    Widget nextPage,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("เข้าสู่ระบบสำเร็จ"),
        content: const Text("กำลังเข้าสู่ระบบ กรุณารอสักครู่..."),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    if (context.mounted) {
      Navigator.of(context).pop(); // ปิด dialog
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
        (route) => false,
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("เข้าสู่ระบบไม่สำเร็จ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }
}

