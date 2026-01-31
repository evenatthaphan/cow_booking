import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  TextEditingController farmNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final farmer = Provider.of<DataFarmers>(context, listen: false).datauser;
    farmNameController.text = farmer.farmersName;
    phoneController.text = farmer.farmersPhonenumber;
    emailController.text = farmer.farmersEmail;
    addressController.text = farmer.farmersAddress;
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกจากแกลลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายภาพใหม่'),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('ยกเลิก'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลส่วนตัว',
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              // CircleAvatar(
              //   radius: 32,
              //   backgroundImage:
              //       Provider.of<DataFarmers>(context).datauser.profileImage.isNotEmpty
              //           ? NetworkImage(
              //               Provider.of<DataFarmers>(context).datauser.profileImage,
              //             )
              //           : const AssetImage('assets/images/profile.jpg')
              //               as ImageProvider,
              // ),
              CircleAvatar(
                radius: 32,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : Provider.of<DataFarmers>(context)
                            .datauser
                            .farmersProfileImage
                            .isNotEmpty
                        ? NetworkImage(
                            Provider.of<DataFarmers>(context)
                                .datauser
                                .farmersProfileImage,
                          )
                        : const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: showImageSourceDialog,
                child: Text(
                  'เปลี่ยนรูปภาพโปรไฟล์',
                  style: GoogleFonts.notoSansThai(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 16,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Text(
                'ชื่อ *',
                style: TextStyle(color: Colors.green[900]),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              controller: farmNameController,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Text(
                'เบอร์โทรศัพท์ *',
                style: TextStyle(color: Colors.green[900]),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Text(
                'อีเมลล์ *',
                style: TextStyle(color: Colors.green[900]),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: FilledButton(
                        onPressed: saveeidt,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green[900]!),
                        ),
                        child: Text(
                          'บันทึก',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> saveeidt() async {
    final farmerId =
        Provider.of<DataFarmers>(context, listen: false).datauser.farmersId;

    final uri = Uri.parse("$apiEndpoint/farmer/edit/$farmerId");
    print("CALL API: $uri");

    var request = http.MultipartRequest("PUT", uri);

    request.fields["farm_name"] = farmNameController.text;
    request.fields["phonenumber"] = phoneController.text;
    request.fields["farmer_email"] = emailController.text;
    request.fields["farm_address"] = addressController.text;

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_image",
          _selectedImage!.path,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print(response.statusCode);
      print(responseBody);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขข้อมูลสำเร็จ")),
        );

        // รีโหลดข้อมูลใหม่ (ถ้ามี API get profile)
        // await Provider.of<DataFarmers>(context, listen:false).fetchProfile();

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขข้อมูลไม่สำเร็จ")),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เชื่อมต่อเซิร์ฟเวอร์ไม่ได้")),
      );
    }
  }
}
