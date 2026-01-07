import 'dart:developer';

import 'package:cow_booking/pages/chooselogin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/recaptcha_stub.dart'
    if (dart.library.html) 'recaptcha_web.dart';

class FarmerRegister extends StatefulWidget {
  const FarmerRegister({super.key});

  @override
  State<FarmerRegister> createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController subdistrictCtrl = TextEditingController();
  final TextEditingController farmAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;


    // ตัวแปรเก็บค่า dropdown
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;

  //example
  List provinces = [];
  List districts = [];
  List subDistricts = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final url = Uri.parse(
      "https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province_with_district_and_sub_district.json",
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        provinces = data;
      });
    } else {
      print("โหลดข้อมูลจังหวัดล้มเหลว");
    }
  }

  @override
  void dispose() {
    farmNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    provinceCtrl.dispose();
    districtCtrl.dispose();
    subdistrictCtrl.dispose();
    farmAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันลงทะเบียน
  Future<void> registerFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("รหัสผ่านไม่ตรงกัน");
      return;
    }

    // แสดง CAPTCHA Dialog
    await showCaptchaDialog();
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
                _showErrorDialog("ไม่สามารถโหลด CAPTCHA ได้");
              }
            } catch (e) {
              _showErrorDialog("เกิดข้อผิดพลาด: $e");
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
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (dialogCaptchaController.text.isEmpty) return;
                        final isValid = await verifyCaptcha(
                            dialogCaptchaId!, dialogCaptchaController.text);
                        if (isValid) {
                          Navigator.of(context).pop();
                          await submitForm();
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
        _showErrorDialog(data['message'] ?? "CAPTCHA ไม่ถูกต้อง");
        return false;
      }
    } catch (e) {
      print("verifyCaptcha error: $e");
      _showErrorDialog("เกิดข้อผิดพลาด: $e");
      return false;
    }
  }

    Future<void> showRegisterSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("สมัครสมาชิกสำเร็จ 🎉"),
        content: const Text("บัญชีของคุณถูกสร้างเรียบร้อยแล้ว กรุณาเข้าสู่ระบบ"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChooseLogin()),
              );
            },
            child: const Text("เข้าสู่ระบบ"),
          ),
        ],
      ),
    );
  }



  Future<void> submitForm() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("$apiEndpoint/farmer/register");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({
          "farm_name": farmNameController.text.trim(),
          "phonenumber": phoneNumberController.text.trim(),
          "farmer_email": emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          "farm_password": passwordController.text.trim(),
          "farm_address": farmAddressController.text.trim(),
          "province": provinceCtrl.text.trim(),
          "district": districtCtrl.text.trim(),
          "locality": subdistrictCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSuccessDialog(data['message'] ?? "ลงทะเบียนสำเร็จ");
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(errorData['error'] ?? "เกิดข้อผิดพลาดในการลงทะเบียน");
      }
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('สำเร็จ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('ตกลง'),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool required) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 30),
      child: Row(
        children: [
          Text(text,
              style:
                  GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey)),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 14),
            )
        ],
      ),
    );
  }

  Widget _buildTextForm(TextEditingController controller, String errorText,
      {TextInputType? keyboardType, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (errorText.isEmpty) return null;
          if (value == null || value.isEmpty) return errorText;
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ลงทะเบียนเกษตรกร',
          style: GoogleFonts.notoSansThai(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildLabel("ชื่อผู้ใช้", true),
              _buildTextForm(farmNameController, "กรุณากรอกชื่อผู้ใช้"),
              _buildLabel("เบอร์โทรศัพท์", true),
              _buildTextForm(phoneNumberController, "กรุณากรอกเบอร์โทรศัพท์",
                  keyboardType: TextInputType.phone),
              _buildLabel("อีเมลล์", false),
              _buildTextForm(emailController, "",
                  keyboardType: TextInputType.emailAddress),
               Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'จังหวัด *',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    value: selectedProvince,
                    items: provinces.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem(
                        value: p["name_th"],
                        child: Text(p["name_th"]),
                      );
                    }).toList(),
                    onChanged: (farmer) {
                      setState(() {
                        selectedProvince = farmer;
                        provinceCtrl.text = farmer ?? '';
                        selectedDistrict = null;
                        selectedSubDistrict = null;

                        // หาอำเภอในจังหวัดที่เลือก
                        final provinceData = provinces.firstWhere(
                          (p) => p["name_th"] == farmer,
                          orElse: () => {},
                        );
                        districts = provinceData["districts"] ?? [];
                        subDistricts = [];
                      });
                    },
                  ),
                ),
              Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'อำเภอ *',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    value: selectedDistrict,
                    items: districts.map<DropdownMenuItem<String>>((d) {
                      return DropdownMenuItem(
                        value: d["name_th"],
                        child: Text(d["name_th"]),
                      );
                    }).toList(),
                    onChanged: (farmer) {
                      setState(() {
                        selectedDistrict = farmer;
                        districtCtrl.text = farmer ?? ''; 
                        selectedSubDistrict = null;

                        // หา “ตำบล” ในอำเภอที่เลือก
                        final districtData = districts.firstWhere(
                          (d) => d["name_th"] == farmer,
                          orElse: () => {},
                        );
                        subDistricts = districtData["sub_districts"] ?? [];
                      });
                    },
                  ),
                ),
              Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'ตำบล *',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    value: selectedSubDistrict,
                    items: subDistricts.map<DropdownMenuItem<String>>((s) {
                      return DropdownMenuItem(
                        value: s["name_th"],
                        child: Text(s["name_th"]),
                      );
                    }).toList(),
                    onChanged: (farmer) {
                      setState(() {
                        selectedSubDistrict = farmer;
                        subdistrictCtrl.text = farmer ?? '';
                      });
                    },
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {}, // TODO: Map picker
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[900]!),
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(20)),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'คลิกเพื่อเลือกตำแหน่งที่อยู่ *',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildTextForm(farmAddressController, "กรุณากรอกที่อยู่"),
              _buildLabel("รหัสผ่าน", true),
              _buildTextForm(passwordController, "กรุณากรอกรหัสผ่าน",
                  obscure: true),
              _buildLabel("ยืนยันรหัสผ่าน", true),
              _buildTextForm(confirmPasswordController, "กรุณายืนยันรหัสผ่าน",
                  obscure: true),
              Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton(
                  onPressed: isLoading ? null : registerFarmer,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 2),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        )
                      : Text(
                          'ลงทะเบียน',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
