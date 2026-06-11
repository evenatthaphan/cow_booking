import 'package:cow_booking/model/response/admin_response.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/Animal_husbandry/home_page_doc.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/pages/admin/admin_change_password.dart';
import 'package:cow_booking/pages/admin/admin_dashbord_page.dart';
import 'package:cow_booking/share/forgot_password_page.dart';
import 'package:cow_booking/share/recaptcha_webview.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:cow_booking/share/share_witget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cow_booking/config/internal_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChooseLogin extends StatefulWidget {
  const ChooseLogin({super.key});

  @override
  State<ChooseLogin> createState() => _ChooseLoginState();
}

class _ChooseLoginState extends State<ChooseLogin> {
  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String url = "";

  final myWidget = MyWidget();
  final handleError = HandleError();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (value) {
        url = value['apiEndpoint'].toString();
      },
    ).catchError((err) {});
  }

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    const siteKey = '6Leg1xUtAAAAALU0bfc2Z2Qz-xboQULyqBPCTEsd';

    String? recaptchaToken;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecaptchaV2Page(
          siteKey: siteKey,
          onTokenReceived: (token) {
            recaptchaToken = token;
          },
        ),
      ),
    );

    if (recaptchaToken == null) {
      debugPrint('⚠️ ไม่ได้รับ reCAPTCHA token');
      return;
    }

    await loginUser(recaptchaToken: recaptchaToken);
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'กรุณากรอกชื่อผู้ใช้ หรืออีเมลล์ หรือเบอร์โทรศัพท์',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Text(
                      'และรหัสผ่านเพื่อเข้าสู่ระบบ',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 30),
                child: Row(
                  children: [
                    Text(
                      'ชื่อผู้ใช้ หรืออีเมลล์ หรือเบอร์โทรศัพท์',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                child: TextField(
                  controller: loginIdController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Colors.green[900]!),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30),
                child: Row(
                  children: [
                    Text(
                      'รหัสผ่าน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
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
                    Text(
                      'คุณลืมรหัสผ่าน?',
                      style: GoogleFonts.notoSansThai(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
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
                    ),
                  ),
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
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'loginId': loginId,
          'password': password,
          if (recaptchaToken != null) 'recaptcha_token': recaptchaToken,
        }),
      );
      debugPrint('Login URL: ${uri.toString()}');
      debugPrint('Status: ${res.statusCode}');
      debugPrint('Body: ${res.body}');

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        final role = data['role'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (role == 'farmer' && user != null) {
          final farmer = Farmers.fromJson(user);
          context.read<DataFarmers>().setDataUser(farmer);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'farmer');
          await prefs.setInt('userId', farmer.farmersId);

          await _showSuccessDialogAndNavigate(context, Homepage());
          return;
        }

        if (role == 'vet' && user != null) {
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

          context.read<DataVetExpert>().setDataUser(vet);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'vet');
          await prefs.setInt('userId', vet.id);

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

          if (admin.mustChangePassword == 1) {
            await _showSuccessDialogAndNavigate(
                context, AdminChangePasswordPage());
          } else {
            await _showSuccessDialogAndNavigate(context, AdminDashboardPage());
          }
          return;
        }

        _showErrorDialog(context, "รูปแบบข้อมูลไม่ถูกต้อง");
      } else if (res.statusCode == 401) {
        _showErrorDialog(context, "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง");
      } else {
        String errorMessage = "เกิดข้อผิดพลาด";
        try {
          final data = jsonDecode(res.body);
          errorMessage = data['error'] ?? data['message'] ?? errorMessage;
        } catch (_) {}
        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      debugPrint('Login error: ${e.toString()}');
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
      builder: (_) => const AlertDialog(
        title: Text("เข้าสู่ระบบสำเร็จ"),
        content: Text("กำลังเข้าสู่ระบบ กรุณารอสักครู่..."),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    if (context.mounted) {
      Navigator.of(context).pop();
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