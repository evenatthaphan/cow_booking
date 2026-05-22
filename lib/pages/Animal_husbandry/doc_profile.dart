import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/cow_list_page.dart';
import 'package:cow_booking/pages/Animal_husbandry/manage_schedule.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_profile_menu.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_stat_page.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/choose_login.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class VetProfilePage extends StatefulWidget {
  const VetProfilePage({super.key});

  @override
  State<VetProfilePage> createState() => _VetProfilePageState();
}

class _VetProfilePageState extends State<VetProfilePage> {

  int _totalStock = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchTotalStock();
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTotalStock();
    });
  }

  Future<void> _fetchTotalStock() async {
    final vetId = Provider.of<DataVetExpert>(context, listen: false).datauser.id;
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/vet/vet-bulls/total-stock/$vetId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _totalStock = data['total_stock'] ?? 0);
      }
    } catch (_) {}
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🐄', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cow Booking',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[900],
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'โปรไฟล์ส',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 11,
                      color: Colors.green[900],
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(color: Colors.lightGreen[900]),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Consumer<DataVetExpert>(
                  builder: (context, dataVet, _) {
                    final imageUrl = dataVet.datauser.profileImage;
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: (imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : const NetworkImage(
                              'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                            ),
                    );
                  },
                ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<DataVetExpert>(
                  builder: (context, dataVet, _) {
                    final Vetname = dataVet.datauser.vetExpertName;
                    return Text(Vetname, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),);
                  },
                ),
                     Consumer<DataVetExpert>(
                  builder: (context, dataVet, _) {
                    final Vetphone = dataVet.datauser.phonenumber;
                    return Text(Vetphone, style: TextStyle(fontSize: 14, color: Colors.grey[600]),);
                  },
                ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VetProfileMenuPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_calendar_outlined),
                const SizedBox(width: 16),
                const Expanded(
                  child: const Text("จัดการตารางงาน",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageschedulePage()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_document),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text("จัดการข้อมูลพ่อพันธ์ุ",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$_totalStock โดส",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CowListPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text("สถิติทั้งหมด",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                const Spacer(),
                const Icon(Icons.stacked_bar_chart, color: Colors.amber),
                const SizedBox(width: 5),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InseminationDashboardStatPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text("ดู", style: TextStyle(
                          fontSize: 16, color: Colors.white),),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // รายการเมนู
          // _buildMenuItem("ผสมสำเร็จแล้วแล้ว"),
          // _buildMenuItem("อยู่ในการรอผล"),
          // _buildMenuItem("ผสมไม่สำเร็จ"),
          const SizedBox(height: 10),
          // _buildMenuItem("ตั้งค่าการแสดงผล"),
          // _buildMenuItem("ตั้งค่าประสิทธิภาพ"),
          // _buildMenuItem("ตั้งค่าการแจ้งเตือน"),
          // _buildMenuItem("ตั้งค่าความเป็นส่วนตัว"),

          const SizedBox(
            height: 10,
          ),

          GestureDetector(
          onTap: () => _logout(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "ออกจากระบบ",
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

 Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');
  await prefs.remove('userType');

  // clear data user in provider
  context.read<DataVetExpert>().setDataUser(
    VetExpert(
      id: 0,
      vetExpertName: "",
      vetExpertPassword: "",
      password: "",
      phonenumber: "",
      vetExpertEmail: "",
      profileImage: "",
      vetExpertAddress: "",
      province: "",
      district: "",
      locality: "",
      vetExpertPl: "",
      totalSemenStock: 0,
    ),
  );

  // ไปหน้า choose login และล้าง stack
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Homepage()),
    (route) => false,
  );
}

}