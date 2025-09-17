import 'package:cow_booking/pages/%E0%B9%89Home/homepage.dart';
import 'package:cow_booking/pages/Animal_husbandry/homepagedoc.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/model/response/LoginResponseGet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:cow_booking/share/ShareWitget.dart';
import 'package:provider/provider.dart';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/request/login_Request.dart';


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
                      onPressed: loginUser,
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

  

  // void login() {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const Homepage(),
  //       ));

  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const Homepage(),
  //       ));
  // }

  //

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
      // คาดรูปแบบ { role: 'farmer'|'vet', message, user: {...} }
      final role = data['role'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (role == 'farmer' && user != null) {
        // เก็บใน Provider เพื่อใช้ข้ามหน้า (ไม่จำเป็นต้องส่ง id)
        final farmer = Farmers.fromJson(user);
        context.read<DataFarmers>().setDataUser(farmer);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Homepage()),
        );
        return;
      }

      if (role == 'vet' && user != null) {
        final vet = VetExpert.fromJson(user);
        context.read<DataVetExpert>().setDataUser(vet);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Homepagedoc()),
        );
        return;
      }

      myWidget.showCustomSnackbar('Message', 'รูปแบบข้อมูลไม่ตรงที่คาดไว้');
    } else {
      handleError.handleError(res);
    }
  } catch (e) {
    debugPrint('Login error: ' + e.toString());
    myWidget.showCustomSnackbar('Message', 'เกิดข้อผิดพลาดระหว่างล็อกอิน $e');
  }
}
}
  


