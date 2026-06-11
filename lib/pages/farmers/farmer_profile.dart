import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/pages/choose_regis.dart';
import 'package:cow_booking/pages/farmers/favorite_page.dart';
import 'package:cow_booking/pages/farmers/history_page.dart';
import 'package:cow_booking/pages/farmers/dashboard_page.dart';
import 'package:cow_booking/pages/farmers/view_profile.dart';
import 'package:cow_booking/pages/choose_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Farmerprofilepage extends StatefulWidget {
  const Farmerprofilepage({super.key});

  @override
  State<Farmerprofilepage> createState() => _FarmerprofilepageState();
}

class _FarmerprofilepageState extends State<Farmerprofilepage> {
  static const _green700 = Color(0xFF2d6a2d);
  static const _green500 = Color(0xFF4CAF50);
  static const _bgColor = Color(0xFFf0f4f0);
  static const _green = Color(0xFF2E7D32);

  // state
  int _totalBookings = 0;
  int _totalLikes = 0;
  int _successRate = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // fetch ใน initState
  Future<void> _fetchStats() async {
    final farmer_id =
        Provider.of<DataFarmers>(context, listen: false).datauser.farmersId;
    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/farmer/farmers/stats/$farmer_id'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _totalBookings = data['total_bookings'] ?? 0;
          _totalLikes = data['total_likes'] ?? 0;
          _successRate = data['success_rate'] ?? 0;
        });
      }
    } catch (_) {}
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          ),
        ),
      ),
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
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'โปรไฟล์ของคุณ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataUser = context.watch<DataFarmers>().datauser;
    final bool isLoggedIn = dataUser.farmersId != 0;

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _bgColor,
      body: isLoggedIn ? _buildLoggedInView(context) : _buildGuestView(context),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildProfileCard(context),
          const SizedBox(height: 16),
          _buildMenuSection(context),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // avatar
                Consumer<DataFarmers>(
                  builder: (context, data, _) {
                    final imageUrl = data.datauser.farmersProfileImage;
                    return Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _green500.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            key: ValueKey(imageUrl),
                            radius: 32,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const NetworkImage(
                                    'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _green500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Consumer<DataFarmers>(
                    builder: (context, data, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.datauser.farmersName,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1a2e1a),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              data.datauser.farmersPhonenumber,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: const Color(0xFF6d8c6d),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Viewprofile())),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFf0f7f0),
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: _green500, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFf0f0f0)),
            const SizedBox(height: 14),
            // Stats row
            Row(
              children: [
                _buildStatItem('$_totalLikes', 'ที่ถูกใจ'),
                _buildStatDivider(),
                _buildStatItem('$_totalBookings', 'ประวัติ'),
                _buildStatDivider(),
                _buildStatItem('$_successRate%', 'อัตราสำเร็จ'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _green700,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.notoSansThai(
                fontSize: 11,
                color: const Color(0xFF8aab8a),
              )),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 30, color: const Color(0xFFf0f0f0));
  }

  Widget _buildMenuSection(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Text('เมนูหลัก',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8aab8a),
                    letterSpacing: 0.5,
                  )),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'ที่ถูกใจ',
                    subtitle: 'วัวที่คุณบันทึกไว้',
                    icon: Icons.favorite_rounded,
                    iconBg: const Color(0xFFfff8e1),
                    iconColor: const Color(0xFFF9A825),
                    isLast: false,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritePage())),
                  ),
                  _buildMenuItem(
                    title: 'ประวัติการผสม',
                    subtitle: 'บันทึกทั้งหมด',
                    icon: Icons.library_books_rounded,
                    iconBg: const Color(0xFFe8f5e9),
                    iconColor: const Color(0xFF43a047),
                    isLast: false,
                    onTap: () {
                      final id = context.read<DataFarmers>().datauser.farmersId;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  InseminationHistoryPage(farmerId: id)));
                    },
                  ),
                  _buildMenuItem(
                    title: 'สถิติทั้งหมด',
                    subtitle: 'ภาพรวมผลลัพธ์',
                    icon: Icons.bar_chart_rounded,
                    iconBg: const Color(0xFFe3f2fd),
                    iconColor: const Color(0xFF1976D2),
                    isLast: true,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InseminationDashboardPage())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isLast,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFf5f5f5))),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1a2e1a),
                      )),
                  Text(subtitle,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: const Color(0xFF8aab8a),
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFc5d9c5), size: 20),
          ],
        ),
      ),
    );
  }

  // ====== Logout button ======
  Widget _buildLogoutButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () => _logout(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfdecea),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFe53935), size: 20),
                ),
                Text('ออกจากระบบ',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFe53935),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====== Guest view ======
  Widget _buildGuestView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8f5e9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline_rounded,
                        size: 50, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  Text('คุณยังไม่ได้เข้าสู่ระบบ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1a2e1a),
                      )),
                  const SizedBox(height: 8),
                  Text('เข้าสู่ระบบเพื่อใช้งานฟีเจอร์ทั้งหมด',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        color: Colors.grey[500],
                      )),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChooseLogin())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('เข้าสู่ระบบ',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Chooseregis())),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _green700, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('สมัครสมาชิก',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            color: _green700,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userType');
    context.read<DataFarmers>().clear();
    if (!mounted) return;
    setState(() {});
  }

  ImageProvider _profileImage(String url) {
    if (url.isEmpty) {
      return const NetworkImage(
          'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png');
    }
    // ✅ เพิ่ม timestamp ทำให้ Flutter มองว่าเป็น URL ใหม่ทุกครั้ง
    final busted = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    return NetworkImage(busted);
  }
}
