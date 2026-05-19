import 'package:cow_booking/pages/farmers/edit_address.dart';
import 'package:cow_booking/pages/farmers/edit_password.dart';
import 'package:cow_booking/pages/farmers/edit_profile.dart';
import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Viewprofile extends StatefulWidget {
  const Viewprofile({super.key});

  @override
  State<Viewprofile> createState() => _ViewprofileState();
}

class _ViewprofileState extends State<Viewprofile> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "จัดการโปรไฟล์",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header โปรไฟล์ 
            Container(
              width: double.infinity,
              color: Colors.lightGreen,
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  Consumer<DataFarmers>(
                    builder: (context, dataFarmer, _) {
                      final imageUrl = dataFarmer.datauser.farmersProfileImage;
                      return CircleAvatar(
                        radius: 44,
                        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                            ? NetworkImage(imageUrl)
                            : const NetworkImage(
                                'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Consumer<DataFarmers>(
                    builder: (context, dataFarmer, _) => Text(
                      dataFarmer.datauser.farmersName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<DataFarmers>(
                    builder: (context, dataFarmer, _) => Text(
                      dataFarmer.datauser.farmersPhonenumber,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // เมนู 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("ตั้งค่าบัญชี"),
                  _menuCard([
                    _menuItem(
                      icon: Icons.person_outline,
                      iconColor: Colors.green,
                      label: "แก้ไขข้อมูลส่วนตัว",
                      subtitle: "ชื่อ, เบอร์โทร, รูปโปรไฟล์",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Editprofilepage()),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _menuItem(
                      icon: Icons.lock_outline,
                      iconColor: Colors.orange,
                      label: "เปลี่ยนรหัสผ่าน",
                      subtitle: "อัพเดตรหัสผ่านของคุณ",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Editpasswoedpage()),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _menuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.blue,
                      label: "แก้ไขที่อยู่",
                      subtitle: "ที่อยู่และพิกัดสถานที่",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditaddressPage()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: FarmerNavigationBar(
      //   selectedIndex: 1,
      //   onDestinationSelected: (value) {},
      //   screenSize: screenSize,
      // ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
              letterSpacing: 0.5),
        ),
      );

  Widget _menuCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
}