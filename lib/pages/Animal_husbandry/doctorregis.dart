import 'package:cow_booking/config/internal_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class DoctorRegis extends StatefulWidget {
  const DoctorRegis({super.key});

  @override
  State<DoctorRegis> createState() => _DoctorRegisState();
}

class _DoctorRegisState extends State<DoctorRegis> {
  final TextEditingController _fileNameController = TextEditingController();

  // ตัวแปรเก็บค่า dropdown
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;

  List provinces = [];
  List districts = [];
  List subDistricts = [];

  File? _imageFile;
  String? _imageFileName;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ลงทะเบียนสัตวบาล',
          style: GoogleFonts.notoSansThai(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 24,
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
                    onChanged: (val) {
                      setState(() {
                        selectedProvince = val;
                        selectedDistrict = null;
                        selectedSubDistrict = null;

                        // หาอำเภอในจังหวัดที่เลือก
                        final provinceData = provinces.firstWhere(
                          (p) => p["name_th"] == val,
                          orElse: () => {},
                        );
                        districts = provinceData["districts"] ?? [];
                        subDistricts = [];
                      });
                    },
                  ),
                ),
                //อำเภอ
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
                    onChanged: (val) {
                      setState(() {
                        selectedDistrict = val;
                        selectedSubDistrict = null;

                        // หา “ตำบล” ในอำเภอที่เลือก
                        final districtData = districts.firstWhere(
                          (d) => d["name_th"] == val,
                          orElse: () => {},
                        );
                        subDistricts = districtData["sub_districts"] ?? [];
                      });
                    },
                  ),
                ),
                //ตำบล
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
                    onChanged: (val) {
                      setState(() {
                        selectedSubDistrict = val;
                      });
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
                  padding: const EdgeInsets.only(top: 5, left: 30, right: 30),
                  child: TextField(
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
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('ใบประกอบวิชาชีพ',
                              style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14,
                                  color: Colors.grey)),
                          Row(
                            children: [
                              Text('หรือใบรับรอง',
                                  style: GoogleFonts.notoSansThai(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14,
                                      color: Colors.grey)),
                              Text(' *',
                                  style: GoogleFonts.notoSansThai(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14,
                                      color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                _showImageSourceOptions(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              child: _imageFile == null
                                  ? const Text(
                                      'คลิกเลือกภาพจากแกลลอรี่',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        _showFullImage(context);
                                      },
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: 180,
                                        height: 80,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: TextField(
                    controller: _fileNameController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "ชื่อไฟล์ภาพ",
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.green),
                      ),
                      suffixIcon: _imageFile != null
                          ? IconButton(
                              icon: const Icon(Icons.image_search,
                                  color: Colors.green),
                              onPressed: () => _showFullImage(context),
                            )
                          : null,
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
                  onPressed: registerVetExpert,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.green, // สีของเส้นขอบ
                      width: 2, // ความหนาของเส้นขอบ
                    ),
                  ),
                  child: Text(
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

  Future<void> registerVetExpert() async {
    try {
      if (_imageFile == null ||
          selectedProvince == null ||
          selectedDistrict == null ||
          selectedSubDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
        );
        return;
      }

      //final url = Uri.parse("$apiEndpoint/vet/register");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiEndpoint/vet/register'),
      );

      request.fields['VetExpert_name'] = 'ชื่อจาก textfield';
      request.fields['VetExpert_password'] = 'รหัสผ่าน';
      request.fields['phonenumber'] = 'เบอร์โทร';
      request.fields['VetExpert_email'] = 'อีเมล';
      request.fields['VetExpert_address'] = 'ที่อยู่';
      request.fields['province'] = selectedProvince!;
      request.fields['district'] = selectedDistrict!;
      request.fields['locality'] = selectedSubDistrict!;

      request.files.add(
        await http.MultipartFile.fromPath('VetExpert_PL', _imageFile!.path),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'ลงทะเบียนสำเร็จ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'ระบบได้รับข้อมูลของคุณแล้ว\nกรุณารอการตรวจสอบจากผู้ดูแลก่อนเข้าใช้งาน',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด dialog
                    Navigator.popUntil(
                        context, (route) => route.isFirst); // กลับหน้าแรก
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ลงทะเบียนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่ภายหลัง')),
      );
    }
  }

  // void backtologin() {
  //   Navigator.popUntil(context, (route) => route.isFirst);
  // }

  void _showFullImage(BuildContext context) {
    if (_imageFile == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Stack(
          children: [
            Image.file(_imageFile!, fit: BoxFit.contain),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('เลือกรูปจากแกลลอรี่'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('ถ่ายภาพใหม่'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageFileName = pickedFile.name;
        _fileNameController.text = _imageFileName ?? '';
      });
    }
  }
}
