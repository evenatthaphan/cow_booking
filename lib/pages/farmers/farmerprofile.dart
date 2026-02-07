import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/pages/chooseregis.dart';
import 'package:cow_booking/pages/farmers/viewprofile.dart';
import 'package:cow_booking/pages/chooselogin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Farmerprofilepage extends StatefulWidget {
  const Farmerprofilepage({super.key});

  @override
  State<Farmerprofilepage> createState() => _FarmerprofilepageState();
}

class _FarmerprofilepageState extends State<Farmerprofilepage> {
  @override
  Widget build(BuildContext context) {
    final dataUser = context.watch<DataFarmers>().datauser;

    final bool isLoggedIn = dataUser.farmersId != 0; // ตรวจว่ามีการเข้าสู่ระบบหรือไม่

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
      body: isLoggedIn ? _buildLoggedInView(context) : _buildGuestView(context),
    );
  }

  // for users logined
  Widget _buildLoggedInView(BuildContext context) {
    return ListView(
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
                child: Consumer<DataFarmers>(
                  builder: (context, dataVet, _) {
                    final imageUrl = dataVet.datauser.farmersProfileImage;
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
                    Consumer<DataFarmers>(
                      builder: (context, dataVet, _) {
                        return Text(
                          dataVet.datauser.farmersName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Consumer<DataFarmers>(
                      builder: (context, dataVet, _) {
                        return Text(
                          dataVet.datauser.farmersPhonenumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        );
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
                        builder: (context) => const Viewprofile()),
                  );
                },
              ),
            ],
          ),
        ),
        _buildMenuItem("ที่ถูกใจ", Icons.favorite),
        _buildMenuItem("ประวัติการผสม", Icons.library_books_sharp),
        _buildMenuItem("สถิติทั้งหมด", Icons.stacked_bar_chart),
        const SizedBox(height: 10),
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
    );
  }

  // for users not login
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              "คุณยังไม่ได้เข้าสู่ระบบ",
              style:
                  GoogleFonts.notoSansThai(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChooseLogin()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text("เข้าสู่ระบบ",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Chooseregis()));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green[900]!),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text("สมัครสมาชิก",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16, color: Colors.green[900])),
            ),
          ],
        ),
      ),
    );
  }

  // simple menu
  Widget _buildMenuItem(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                )),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  

  // fucntion logout
  Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');
  await prefs.remove('userType');

  // clear data user in provider
  context.read<DataFarmers>().clear();

  if (!mounted) return;
  setState(() {});
}

  // Future<void> _logout(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('isLoggedIn');
  //   await prefs.remove('userType');

  //   // clear data user in provider
  //   context.read<DataFarmers>().setDataUser(Farmers(
  //       farmersId: 0,
  //       farmersName: "" ,
  //       farmesHashpassword: "",
  //       farmersPassword : "",
  //       farmersPhonenumber: "",
  //       farmersEmail: "",
  //       farmersProfileImage: "",
  //       farmersAddress: "",
  //       farmersProvince: "",
  //       farmersDistrict: "",
  //       farnersLocality: "",
  //       farmersLocLat: null,
  //       farmersLocLong: null,
  //       ));

  //   setState(() {});
  // }
}
