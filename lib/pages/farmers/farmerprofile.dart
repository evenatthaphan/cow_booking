import 'package:cow_booking/pages/farmers/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Farmerprofilepage extends StatefulWidget {
  const Farmerprofilepage({super.key});

  @override
  State<Farmerprofilepage> createState() => _FarmerprofilepageState();
}

class _FarmerprofilepageState extends State<Farmerprofilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text('โปรไฟล์',
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
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('kunnoomnimm',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('0611254785',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Viewprofile()),
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
                Icon(Icons.favorite),
                SizedBox(width: 16),
                Expanded(
                  child: Text("ที่ถูกใจ",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                      )),
                ),
                Text("5"),
                Icon(Icons.arrow_forward_ios, size: 16),
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
                Icon(Icons.library_books_sharp),
                SizedBox(width: 16),
                Expanded(
                  child: Text("ประวัติการผสม",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                      )),
                ),
                Text("5"),
                Icon(Icons.arrow_forward_ios, size: 16),
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
                Text("สถิติทั้งหมด",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                    )),
                const Spacer(),
                const Icon(Icons.stacked_bar_chart, color: Colors.amber),
                const SizedBox(width: 5),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text("ดู", style: GoogleFonts.notoSansThai(
                          fontSize: 16, color: Colors.white),),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // รายการเมนู
          _buildMenuItem("ผสมสำเร็จแล้วแล้ว"),
          _buildMenuItem("อยู่ในการรอผล"),
          _buildMenuItem("ผสมไม่สำเร็จ"),
          const SizedBox(height: 10),
          // _buildMenuItem("ตั้งค่าการแสดงผล"),
          // _buildMenuItem("ตั้งค่าประสิทธิภาพ"),
          // _buildMenuItem("ตั้งค่าการแจ้งเตือน"),
          // _buildMenuItem("ตั้งค่าความเป็นส่วนตัว"),

          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                    child: Text("ออกจากระบบ",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          color: Colors.red,
                        ))),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.white,
          title: Text(title, style: GoogleFonts.notoSansThai(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
