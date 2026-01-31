import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/Animal_husbandry/homepagedoc.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/pages/farmers/farmerprofile.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:cow_booking/share/ShareWitget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/recaptcha_stub.dart'
    if (dart.library.html) 'recaptcha_web.dart';
import 'dart:developer';

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
      myWidget.showCustomSnackbar("Message", 'Error in initState: $err');
    });
  }

   // CAPTCHA Dialog
  Future<void> showCaptchaDialog() async {
    String? dialogCaptchaId;
    String? dialogCaptchaCode;
    TextEditingController dialogCaptchaController = TextEditingController();
    bool loading = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          Future<void> fetchCaptcha() async {
            setState(() {
              loading = true;
            });
            try {
              final url = Uri.parse("$apiEndpoint/api/captcha");
              final response = await http.get(url);
              if (response.statusCode == 201) {
                final data = jsonDecode(response.body);
                setState(() {
                  dialogCaptchaId = data['captchaId'];
                  dialogCaptchaCode = data['captcha'];
                });
              } else {
                _showErrorDialog(context, "ไม่สามารถโหลด CAPTCHA ได้");
              }
            } catch (e) {
              _showErrorDialog(context, "เกิดข้อผิดพลาด: $e");
            } finally {
              setState(() {
                loading = false;
              });
            }
          }

          if (dialogCaptchaId == null) fetchCaptcha();

          return AlertDialog(
            title: const Text("กรอกตัวอักษรให้ถูกต้องเพื่อยืนยันตัวตน"),
            content: loading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            dialogCaptchaCode ?? "",
                            style:
                                const TextStyle(fontSize: 18, letterSpacing: 2),
                          ),
                          IconButton(
                            onPressed: fetchCaptcha,
                            icon:
                                const Icon(Icons.refresh, color: Colors.green),
                          ),
                        ],
                      ),
                      TextField(
                        controller: dialogCaptchaController,
                        decoration: const InputDecoration(
                          labelText: "กรอก CAPTCHA",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("ยกเลิก"),
              ),
              // ElevatedButton(
              //   onPressed: loading
              //       ? null
              //       : () async {
              //           if (dialogCaptchaController.text.isEmpty) return;
              //           final isValid = await verifyCaptcha(
              //               dialogCaptchaId!, dialogCaptchaController.text);
              //           if (isValid) {
              //             Navigator.of(context).pop();
              //             await loginUser();
              //           } else {
              //             await fetchCaptcha();
              //             dialogCaptchaController.clear();
              //           }
              //         },
              //   child: const Text("ยืนยัน"),
              // ),

              ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (dialogCaptchaController.text.isEmpty) return;

                      final isValid = await verifyCaptcha(
                        dialogCaptchaId!,
                        dialogCaptchaController.text,
                      );

                      if (isValid) {
                        Navigator.of(context).pop();
                        await loginUser(); // 
                      } else {
                        await fetchCaptcha();
                        dialogCaptchaController.clear();
                      }
                    },
              child: const Text("ยืนยัน"),
            ),

            ],
          );
        });
      },
    );
  }

  Future<bool> verifyCaptcha(String captchaId, String answer) async {
    try {
      final url = Uri.parse("$apiEndpoint/api/captcha/verify");
      print("POST to: $url");
      print("Body: ${jsonEncode({"captchaId": captchaId, "answer": answer})}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"captchaId": captchaId, "answer": answer}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        _showErrorDialog(data['message'] ?? context, "CAPTCHA ไม่ถูกต้อง");
        return false;
      }
    } catch (e) {
      print("verifyCaptcha error: $e");
      _showErrorDialog(context, "เกิดข้อผิดพลาด: $e");
      return false;
    }
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
                        Text('คลิก',
                            style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              decoration:
                                  TextDecoration.underline, // ขีดเส้นใต้
                              decorationColor: Colors.green, // สีของเส้นใต้
                              decorationThickness: 2, // ความหนาของเส้นใต้
                            )),
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
                      onPressed: showCaptchaDialog,
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

        // if (role == 'farmer' && user != null) {
        //   final farmer = Farmers.fromJson(user);
        //   context.read<DataFarmers>().setDataUser(farmer);
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (_) => Homepage()),
        //   );
        //   return;
        // }

        if (role == 'farmer' && user != null) {
          final farmer = Farmers.fromJson(user);
          context.read<DataFarmers>().setDataUser(farmer);

          // SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'farmer');
          await prefs.setInt('userId', farmer.farmersId);

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => Homepage()),
          // );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
            (route) => false,
          );
          return;
        }

        if (role == 'vet' && user != null) {
          final vet = VetExpert.fromJson(user);
          context.read<DataVetExpert>().setDataUser(vet);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userType', 'vet');
          await prefs.setInt('userId', vet.id);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Homepagedoc()),
          );
          return;
        }

        // not role/user
        _showErrorDialog(context, "รูปแบบข้อมูลไม่ถูกต้อง");
      } else if (res.statusCode == 401) {
        // Username/Password wrong
        _showErrorDialog(context, "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง");
      } else {
        handleError.handleError(res);
      }
    } catch (e) {
      debugPrint('Login error: ' + e.toString());
      myWidget.showCustomSnackbar('Message', 'เกิดข้อผิดพลาดระหว่างล็อกอิน $e');
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
