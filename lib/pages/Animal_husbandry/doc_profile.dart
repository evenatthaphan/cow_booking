import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/cow_list_page.dart';
import 'package:cow_booking/pages/Animal_husbandry/manage_schedule.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_profile_menu.dart';
import 'package:cow_booking/pages/Animal_husbandry/vet_stat_page.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/share/share_data.dart';
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

  // ── สีหลัก ──
  static const _darkGreen = Color(0xFF1B5E20);
  static const _green = Color(0xFF2E7D32);
  static const _midGreen = Color(0xFF43A047);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _pageBg = Color(0xFFF1F8F1);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _border = Color(0xFFD8EDD8);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _textSecondary = Color(0xFF5A7A5A);
  static const _labelColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTotalStock());
  }

  Future<void> _fetchTotalStock() async {
    final vetId =
        Provider.of<DataVetExpert>(context, listen: false).datauser.id;
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

  // ── Menu item card ──
  Widget _buildMenuCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: GoogleFonts.notoSansThai(
                            fontSize: 12, color: _labelColor)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: _labelColor),
          ],
        ),
      ),
    );
  }

  // ── Section label ──
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(text,
          style: GoogleFonts.notoSansThai(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _labelColor,
              letterSpacing: 0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          // ── Profile header card ──
          Consumer<DataVetExpert>(
            builder: (_, dataVet, __) {
              final vet = dataVet.datauser;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_darkGreen, _midGreen],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: vet.profileImage.isNotEmpty
                              ? NetworkImage(vet.profileImage)
                              : const NetworkImage(
                                  'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // ข้อมูล
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vet.vetExpertName.isNotEmpty
                                  ? vet.vetExpertName
                                  : 'กำลังโหลด...',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (vet.phonenumber.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(vet.phonenumber,
                                      style: GoogleFonts.notoSansThai(
                                          fontSize: 12,
                                          color: Colors.white70)),
                                ],
                              ),
                            ],
                            if (vet.province.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    [vet.district, vet.province]
                                        .where((s) => s.isNotEmpty)
                                        .join(', '),
                                    style: GoogleFonts.notoSansThai(
                                        fontSize: 12,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // ปุ่มแก้ไข
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VetProfileMenuPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── stock summary bar ──
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_outlined,
                    size: 18, color: _green),
                const SizedBox(width: 10),
                Text('น้ำเชื้อในสต็อกทั้งหมด',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 13, color: _textSecondary)),
                const Spacer(),
                Text(
                  '$_totalStock โดส',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _green),
                ),
              ],
            ),
          ),

          // ── จัดการ ──
          _sectionLabel('จัดการ'),

          _buildMenuCard(
            icon: Icons.edit_calendar_outlined,
            iconBg: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1565C0),
            title: 'จัดการตารางงาน',
            subtitle: 'เพิ่ม / แก้ไขช่วงเวลาว่าง',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManageschedulePage())),
          ),

          _buildMenuCard(
            icon: Icons.biotech_outlined,
            iconBg: _lightGreen,
            iconColor: _green,
            title: 'จัดการข้อมูลพ่อพันธุ์',
            subtitle: 'สต็อกน้ำเชื้อที่มีอยู่',
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Text(
                '$_totalStock โดส',
                style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _green),
              ),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CowListPage())),
          ),

          // ── ข้อมูล ──
          _sectionLabel('ข้อมูล'),

          _buildMenuCard(
            icon: Icons.bar_chart_rounded,
            iconBg: const Color(0xFFFFF8E1),
            iconColor: const Color(0xFFF57F17),
            title: 'สถิติการผสมเทียม',
            subtitle: 'ดูอัตราสำเร็จและรายงาน',
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.stacked_bar_chart,
                  color: Color(0xFFF57F17), size: 16),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const InseminationDashboardStatPage()),
            ),
          ),

          // ── บัญชี ──
          _sectionLabel('บัญชี'),

          // ออกจากระบบ
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              margin: const EdgeInsets.fromLTRB(16, 5, 16, 30),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text('ออกจากระบบ',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout confirm dialog ──
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('ออกจากระบบ',
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w700)),
        content: Text('คุณต้องการออกจากระบบหรือไม่?',
            style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก',
                style: GoogleFonts.notoSansThai(color: _labelColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('ออกจากระบบ',
                style: GoogleFonts.notoSansThai(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _logout(context);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userType');
    context.read<DataVetExpert>().setDataUser(
          VetExpert(
            id: 0,
            vetExpertName: '',
            vetExpertPassword: '',
            password: '',
            phonenumber: '',
            vetExpertEmail: '',
            profileImage: '',
            vetExpertAddress: '',
            province: '',
            district: '',
            locality: '',
            vetExpertPl: '',
            totalSemenStock: 0,
          ),
        );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Homepage()),
      (route) => false,
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: Colors.green[900]),
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
                'โปรไฟล์',
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }
}