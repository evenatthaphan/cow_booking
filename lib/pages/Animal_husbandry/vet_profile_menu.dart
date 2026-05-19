import 'package:cow_booking/pages/Animal_husbandry/doc_profile.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_change_password.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_edit_address.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_edit_profile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: import หน้าที่จะสร้างทีหลัง
// import 'package:cow_booking/pages/Animal_husbandry/vet_edit_profile.dart';
// import 'package:cow_booking/pages/Animal_husbandry/vet_change_password.dart';
// import 'package:cow_booking/pages/Animal_husbandry/vet_edit_address.dart';

class VetProfileMenuPage extends StatelessWidget {
  const VetProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color:  Colors.lightGreen[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "จัดการบัญชี",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.lightGreen[800]),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const VetProfilePage()),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.only(right: 12),
        //       child: Consumer<DataVetExpert>(
        //         builder: (context, dataVet, _) {
        //           final imageUrl = dataVet.datauser.profileImage;
        //           return CircleAvatar(
        //             radius: 20,
        //             backgroundImage: imageUrl.isNotEmpty
        //                 ? NetworkImage(imageUrl)
        //                 : const NetworkImage(
        //                     'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
        //                   ),
        //           );
        //         },
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              color:  Colors.lightGreen,
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Consumer<DataVetExpert>(
                      builder: (context, dataVet, _) {
                        final imageUrl = dataVet.datauser.profileImage;
                        return CircleAvatar(
                          radius: 44,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const NetworkImage(
                                  'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<DataVetExpert>(
                    builder: (context, dataVet, _) => Text(
                      dataVet.datauser.vetExpertName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<DataVetExpert>(
                    builder: (context, dataVet, _) => Text(
                      dataVet.datauser.phonenumber,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VetEditProfilePage()));
                        // _comingSoon(context);
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _menuItem(
                      icon: Icons.lock_outline,
                      iconColor: Colors.orange,
                      label: "เปลี่ยนรหัสผ่าน",
                      subtitle: "อัพเดตรหัสผ่านของคุณ",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VetChangePasswordPage()));
                        // _comingSoon(context);
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _menuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.blue,
                      label: "แก้ไขที่อยู่",
                      subtitle: "ที่อยู่และพิกัดสถานที่",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VetEditAddressPage()));
                        // _comingSoon(context);
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ยังไม่ได้เปิดใช้งาน'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
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
                            fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
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