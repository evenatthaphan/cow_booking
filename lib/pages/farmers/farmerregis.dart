import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';

import 'package:provider/provider.dart';
import 'package:cow_booking/share/ShareData.dart';

class FarmerRegister extends StatefulWidget {
  const FarmerRegister({super.key});

  @override
  State<FarmerRegister> createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  // TextEditingController สำหรับฟอร์ม
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

  // ตัวแปรสำหรับ loading state
  bool isLoading = false;
  bool isLoadingLocations = false;

  // // ตัวแปรเก็บข้อมูล location จาก database
  // List<String> provinces = [];
  // List<String> districts = [];
  // List<String> subDistricts = [];

  // ตัวแปรสำหรับ custom input
  final TextEditingController customProvinceController =
      TextEditingController();
  final TextEditingController customDistrictController =
      TextEditingController();
  final TextEditingController customSubDistrictController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // loadProvinces();
  }

  // // ฟังก์ชันโหลดข้อมูลจังหวัด
  // Future<void> loadProvinces() async {
  //   setState(() {
  //     isLoadingLocations = true;
  //   });

  //   try {
  //     final url = Uri.parse("$apiEndpoint/farmer/locations/provinces");
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         provinces = List<String>.from(data['provinces'] ?? []);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading provinces: $e');
  //   } finally {
  //     setState(() {
  //       isLoadingLocations = false;
  //     });
  //   }
  // }

  // // ฟังก์ชันโหลดข้อมูลอำเภอ
  // Future<void> loadDistricts(String province) async {
  //   setState(() {
  //     isLoadingLocations = true;
  //     districts = [];
  //     subDistricts = [];
  //     selectedDistrict = null;
  //     selectedSubDistrict = null;
  //   });

  //   try {
  //     final url = Uri.parse(
  //         "$apiEndpoint/farmer/locations/districts/province=${Uri.encodeComponent(province)}");
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         districts = List<String>.from(data['districts'] ?? []);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading districts: $e');
  //   } finally {
  //     setState(() {
  //       isLoadingLocations = false;
  //     });
  //   }
  // }

  // // ฟังก์ชันโหลดข้อมูลตำบล
  // Future<void> loadSubDistricts(String province, String district) async {
  //   setState(() {
  //     isLoadingLocations = true;
  //     subDistricts = [];
  //     selectedSubDistrict = null;
  //   });

  //   try {
  //     final url = Uri.parse(
  //         "$apiEndpoint/farmer/locations/localities/${Uri.encodeComponent(province)}/${Uri.encodeComponent(district)}");
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         subDistricts = List<String>.from(data['subdistricts'] ?? []);
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading subdistricts: $e');
  //   } finally {
  //     setState(() {
  //       isLoadingLocations = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ลงทะเบียนเกษตรกร',
          style: GoogleFonts.notoSansThai(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดสีของไอคอนใน AppBar ให้เป็นสีขาว
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('กรุณากรอกข้อมูลเพื่อลงทะเบียนสมาชิก และเข้าใช้งานระบบ',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.green)),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('ชื่อผู้ใช้',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    controller: farmNameController,
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
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('เบอร์โทรศัพท์',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
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
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Row(
                    children: [
                      Text('อีเมลล์',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      // Text(' *',
                      //     style: GoogleFonts.notoSansThai(
                      //         textStyle:
                      //             Theme.of(context).textTheme.displayLarge,
                      //         fontSize: 14,
                      //         color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
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

                //จังหวัด
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextFormField(
                    controller: provinceCtrl,
                    decoration: InputDecoration(
                      labelText: "จังหวัด *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอกจังหวัด";
                      }
                      return null;
                    },
                  ),
                ),

                //อำเภอ
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextFormField(
                    controller: districtCtrl,
                    decoration: InputDecoration(
                      labelText: "อำเภอ *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอกอำเภอ";
                      }
                      return null;
                    },
                  ),
                ),

                //ตำบล
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextFormField(
                    controller: subdistrictCtrl,
                    decoration: InputDecoration(
                      labelText: "ตำบล *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอกตำบล";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green[900]!),
                          shape: MaterialStateProperty.all<CircleBorder>(
                            CircleBorder(), // ทำให้ปุ่มเป็นวงกลม
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(20), // กำหนดขนาดของปุ่ม
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on, // ชื่อไอคอน
                          color: Colors.white, // สีของไอคอน
                          size: 20, // ขนาดของไอคอน
                        ),
                      ),
                      Text('   คลิกเพื่อเลือกตำแหน่งที่อยู่',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.grey)),
                      Text(' *',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                              color: Colors.red))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextField(
                    controller: farmAddressController,
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 30),
              child: Row(
                children: [
                  Text('รหัสผ่าน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey)),
                  Text(' *',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.red))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
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
              padding: const EdgeInsets.only(top: 10, left: 30),
              child: Row(
                children: [
                  Text('ยืนยันรหัสผ่าน',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.grey)),
                  Text(' *',
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Colors.red))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
              child: TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), // สีกรอบปกติ
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
              padding: const EdgeInsets.all(10),
              child: OutlinedButton(
                  onPressed: isLoading ? null : registerFarmer,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.green, // สีของเส้นขอบ
                      width: 2, // ความหนาของเส้นขอบ
                    ),
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
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับลงทะเบียนเกษตรกร
  Future<void> registerFarmer() async {
    // ตรวจสอบข้อมูลที่จำเป็น
    if (!_validateForm()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("$apiEndpoint/farmer/register");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        },
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
        _showSuccessDialog(data['message'] ?? 'ลงทะเบียนสำเร็จ');
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(errorData['error'] ?? 'เกิดข้อผิดพลาดในการลงทะเบียน');
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันตรวจสอบข้อมูลฟอร์ม
  bool _validateForm() {
    if (farmNameController.text.trim().isEmpty) {
      _showErrorDialog('กรุณากรอกชื่อผู้ใช้');
      return false;
    }

    if (phoneNumberController.text.trim().isEmpty) {
      _showErrorDialog('กรุณากรอกเบอร์โทรศัพท์');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showErrorDialog('กรุณากรอกรหัสผ่าน');
      return false;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      _showErrorDialog('กรุณายืนยันรหัสผ่าน');
      return false;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showErrorDialog('รหัสผ่านไม่ตรงกัน');
      return false;
    }

    // if (selectedProvince == null) {
    //   _showErrorDialog('กรุณาเลือกจังหวัด');
    //   return false;
    // }

    // if (selectedDistrict == null) {
    //   _showErrorDialog('กรุณาเลือกอำเภอ');
    //   return false;
    // }

    // if (selectedSubDistrict == null) {
    //   _showErrorDialog('กรุณาเลือกตำบล');
    //   return false;
    // }

    if (farmAddressController.text.trim().isEmpty) {
      _showErrorDialog('กรุณากรอกที่อยู่');
      return false;
    }

    return true;
  }

  // ฟังก์ชันแสดง Dialog เมื่อลงทะเบียนสำเร็จ
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สำเร็จ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              backtologin();
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog เมื่อเกิดข้อผิดพลาด
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void backtologin() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ฟังก์ชันสร้าง custom dropdown ที่สามารถเพิ่มรายการใหม่ได้
  Widget _buildLocationDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required Function(String) onAddNew,
    required TextEditingController customController,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.green[900]!),
            ),
          ),
          value: value,
          items: [
            ...items.map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                )),
            const DropdownMenuItem(
              value: '__ADD_NEW__',
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('เพิ่มใหม่...', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
          onChanged: enabled
              ? (val) {
                  if (val == '__ADD_NEW__') {
                    _showAddNewDialog(label, customController, onAddNew);
                  } else {
                    onChanged(val);
                  }
                }
              : null,
        ),
        if (isLoadingLocations)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('กำลังโหลด...', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  // ฟังก์ชันแสดง dialog สำหรับเพิ่มรายการใหม่
  void _showAddNewDialog(String label, TextEditingController controller,
      Function(String) onAddNew) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เพิ่ม$label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'กรอก$label ที่ต้องการ',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'กรอก$label',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.clear();
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                onAddNew(controller.text.trim());
              }
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    farmNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    farmAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    customProvinceController.dispose();
    customDistrictController.dispose();
    customSubDistrictController.dispose();
    super.dispose();
  }
}
