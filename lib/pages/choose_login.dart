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

  final myWidget = MyWidget();
  final handleError = HandleError();

  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (value) {
        // showCustomSnackbar("Message", 'Configuration loaded $value');
        url = value['apiEndpoint'].toString();
      },
    ).catchError((err) {
      // myWidget.showCustomSnackbar("Message", 'Error in initState: $err');
    });
  }

  // CAPTCHA Dialog แบบ Jigsaw Slider
  Future<void> showCaptchaDialog() async {
    // ดึงคีย์จากไฟล์ .env มาใช่เพื่อความปลอดภัย
    final String siteKey = dotenv.env['RECAPTCHA_ANDROID_KEY'] ?? '';
    debugPrint('🔑 reCAPTCHA key loaded from .env: ${siteKey.isNotEmpty ? "✅" : "❌ missing"}');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "ยืนยันตัวตน",
            style: GoogleFonts.notoSansThai(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: JigsawSliderCaptcha(
            onSuccess: () async {
              Navigator.of(context).pop();
              await loginUser();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.notoSansThai(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
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
                      onPressed: () {
                        if (loginIdController.text.trim().isEmpty ||
                            passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    'กรุณากรอกชื่อผู้ใช้หรือรหัสผ่าน',
                                    style: GoogleFonts.notoSansThai(
                                        color: Colors.white),
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
                        } else {
                          showCaptchaDialog();
                        }
                      },
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

  Future<void> loginUser() async {
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
        body: jsonEncode({'loginId': loginId, 'password': password}),
      );
      debugPrint('Login URL: ' + uri.toString());
      debugPrint('Status: ' + res.statusCode.toString());
      debugPrint('Body: ' + res.body.toString());

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

class JigsawSliderCaptcha extends StatefulWidget {
  final VoidCallback onSuccess;

  const JigsawSliderCaptcha({
    super.key,
    required this.onSuccess,
  });

  @override
  State<JigsawSliderCaptcha> createState() => _JigsawSliderCaptchaState();
}

class _JigsawSliderCaptchaState extends State<JigsawSliderCaptcha> {
  double _sliderValue = 0.0;
  late double _targetX;
  final double _targetY = 60.0;
  final double _imageWidth = 280.0;
  final double _imageHeight = 160.0;
  final double _pieceSize = 40.0;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _generateRandomTarget();
  }

  void _generateRandomTarget() {
    final random = Random();
    _targetX = 80.0 + random.nextDouble() * 120.0;
    _sliderValue = 0.0;
    _showError = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/imagecow.jpg',
                width: _imageWidth,
                height: _imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: _targetX,
              top: _targetY,
              child: Container(
                width: _pieceSize,
                height: _pieceSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.extension,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              left: _sliderValue,
              top: _targetY,
              child: Container(
                width: _pieceSize,
                height: _pieceSize,
                decoration: BoxDecoration(
                  color: Colors.green[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.extension,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: _imageWidth,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.green[800],
              trackHeight: 30,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
            ),
            child: Slider(
              value: _sliderValue,
              min: 0.0,
              max: _imageWidth - _pieceSize,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
              onChangeEnd: (value) {
                if ((value - _targetX).abs() < 10.0) {
                  widget.onSuccess();
                } else {
                  setState(() {
                    _showError = true;
                    _sliderValue = 0.0;
                  });
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _showError = false;
                      });
                    }
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _showError ? "ลองอีกครั้ง!" : "เลื่อนเพื่อต่อจิ๊กซอว์ให้ตรงช่อง",
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _showError ? Colors.red : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
