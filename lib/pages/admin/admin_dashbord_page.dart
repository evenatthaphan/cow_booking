import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/admin_list.dart';
import 'package:cow_booking/pages/admin/bull_list.dart';
import 'package:cow_booking/pages/admin/farm_list.dart';
import 'package:cow_booking/pages/admin/member_list.dart';
import 'package:cow_booking/pages/admin/vet_approval.dart';
import 'package:cow_booking/pages/admin/insemination_history.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// TODO: import หน้าอื่นๆ เมื่อสร้างแล้ว
// import 'package:cow_booking/pages/admin/admin_list.dart';
// import 'package:cow_booking/pages/admin/member_list.dart';
// import 'package:cow_booking/pages/admin/vet_approval.dart';
// import 'package:cow_booking/pages/admin/farm_list.dart';
// import 'package:cow_booking/pages/admin/bull_list.dart';
// import 'package:cow_booking/pages/admin/insemination_history.dart';
// import 'package:cow_booking/pages/admin/admin_profile.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;

  // Stats 
  int _totalBookings    = 0;
  int _totalFarmers     = 0;
  int _totalVets        = 0;
  int _pendingApprovals = 0;
  double _successRate   = 0.0;

  // Trend รายเดือน 
  List<Map<String, dynamic>> _monthlyTrend = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
  }


  // Future<void> _fetchStats() async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse('$apiEndpoint/admin/dashboard/stats'),
  //     );
  //     final trendRes = await http.get(
  //       Uri.parse('$apiEndpoint/admin/dashboard/trend'),
  //     );

  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body);
  //       setState(() {
  //         _totalBookings    = data['total_bookings']    ?? 0;
  //         _totalFarmers     = data['total_farmers']     ?? 0;
  //         _totalVets        = data['total_vets']        ?? 0;
  //         _pendingApprovals = data['pending_approvals'] ?? 0;
  //         _successRate      = (data['success_rate']     ?? 0).toDouble();
  //       });
  //     }

  //     if (trendRes.statusCode == 200) {
  //       final trendData = jsonDecode(trendRes.body) as List;
  //       setState(() {
  //         _monthlyTrend = trendData.cast<Map<String, dynamic>>();
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('fetch stats error: $e');
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }




  Future<void> _fetchStats() async {
    if (!mounted) return;
    final auth = context.read<DataAdmin>();

    try {
      final headers = {
        'Content-Type': 'application/json',
        'admin-type': auth.datauser.adminType.toString(),
      };

      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/dashboard/stats'),
        headers: headers,
      );

      final trendRes = await http.get(
        Uri.parse('$apiEndpoint/admin/dashboard/trend'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _totalBookings    = data['total_bookings']    ?? 0;
          _totalFarmers     = data['total_farmers']     ?? 0;
          _totalVets        = data['total_vets']        ?? 0;
          _pendingApprovals = data['pending_approvals'] ?? 0;
          _successRate      = (data['success_rate']     ?? 0).toDouble();
        });
      }

      if (res.statusCode == 403) {
        // ไม่มีสิทธิ์ → กลับไปหน้า login หรือแสดง dialog
        _showNoPermissionDialog();
      }

      if (trendRes.statusCode == 200) {
        final trendData = jsonDecode(trendRes.body) as List;
        setState(() {
          _monthlyTrend = trendData.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint('fetch stats error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNoPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ไม่มีสิทธิ์เข้าถึง'),
        content: Text('บัญชีของคุณไม่มีสิทธิ์ใช้งานฟังก์ชันนี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('ยังไม่ได้เปิดใช้งาน'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final admin    = Provider.of<DataAdmin>(context).datauser;
    final adminType = admin.adminType;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('แดชบอร์ด',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          // ปุ่มโปรไฟล์
          GestureDetector(
            onTap: _comingSoon,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green[200],
                child: Text(
                  admin.adminsName.isNotEmpty ? admin.adminsName[0].toUpperCase() : 'A',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              color: Colors.green,
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Welcome 
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[700]!, Colors.green[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Text(
                              admin.adminsName.isNotEmpty
                                  ? admin.adminsName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('สวัสดี, ${admin.adminsName}',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _adminTypeLabel(adminType),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Cards
                    _sectionLabel('ภาพรวมระบบ'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard('การจองทั้งหมด', '$_totalBookings',
                            Icons.event_note, Colors.green),
                        _statCard('เกษตรกร', '$_totalFarmers',
                            Icons.agriculture, Colors.blue),
                        _statCard('สัตวบาล', '$_totalVets',
                            Icons.medical_services_outlined, Colors.orange),
                        _statCard('รออนุมัติ', '$_pendingApprovals',
                            Icons.pending_actions, Colors.red),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Success Rate
                    _sectionLabel('อัตราความสำเร็จการผสมเทียม'),
                    _infoCard([
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Success Rate',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800])),
                                Text('${_successRate.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _successRate >= 70
                                            ? Colors.green
                                            : Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _successRate / 100,
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                color: _successRate >= 70
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                Text('100%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // แนวโน้มรายเดือน
                    _sectionLabel('แนวโน้มรายเดือน'),
                    _infoCard([
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _monthlyTrend.isEmpty
                            ? Center(
                                child: Text('ยังไม่มีข้อมูล',
                                    style: TextStyle(color: Colors.grey[400])),
                              )
                            : Column(
                                children: _monthlyTrend.map((item) {
                                  final rate = (item['success_rate'] ?? 0).toDouble();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            item['month']?.toString() ?? '-',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: rate / 100,
                                              minHeight: 10,
                                              backgroundColor: Colors.grey[200],
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('${rate.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // เมนูจัดการ
                    _sectionLabel('จัดการระบบ'),
                    _menuCard([
                      // แสดงเฉพาะ Master + Super
                      if (adminType <= 2) ...[
                        _menuItem(
                          icon: Icons.admin_panel_settings_outlined,
                          iconColor: Colors.purple,
                          label: 'จัดการผู้ดูแลระบบ',
                          subtitle: 'เพิ่ม แก้ไข ลบ Admin',
                          onTap: 
                            //_comingSoon
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminListPage())),
                        ),
                        const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                      ],
                      _menuItem(
                        icon: Icons.people_outline,
                        iconColor: Colors.blue,
                        label: 'จัดการสมาชิก',
                        subtitle: 'ดูและค้นหาสมาชิกทั้งหมด',
                        // onTap: _comingSoon,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MemberListPage())),
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                      _menuItem(
                        icon: Icons.verified_user_outlined,
                        iconColor: Colors.orange,
                        label: 'อนุมัติสัตวบาล',
                        subtitle: 'ตรวจสอบใบประกอบวิชาชีพ',
                        //onTap: _comingSoon,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const VetApprovalPage())),
                        trailing: _pendingApprovals > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$_pendingApprovals',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )
                            : null,
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                      _menuItem(
                        icon: Icons.home_work_outlined,
                        iconColor: Colors.teal,
                        label: 'จัดการฟาร์ม',
                        subtitle: 'เพิ่ม แก้ไข ลบ ข้อมูลฟาร์ม',
                        //onTap: _comingSoon,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FarmListPage())),
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                      _menuItem(
                        icon: Icons.pets,
                        iconColor: Colors.brown,
                        label: 'จัดการพ่อพันธุ์',
                        subtitle: 'ข้อมูลวัวพ่อพันธุ์ทั้งหมด',
                        //onTap: _comingSoon,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const BullListPage())),
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                      _menuItem(
                        icon: Icons.history,
                        iconColor: Colors.indigo,
                        label: 'ประวัติการผสมเทียม',
                        subtitle: 'ดูประวัติทั้งหมด',
                        // onTap: _comingSoon,
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const InseminationHistoryPage())),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ออกจากระบบ
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(),
                        icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                        label: const Text('ออกจากระบบ',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจากระบบ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<DataAdmin>(context, listen: false).clear();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              // TODO: Navigator ไปหน้า Login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _adminTypeLabel(int type) {
    switch (type) {
      case 1: return 'Master Admin';
      case 2: return 'Super Admin';
      default: return 'Admin';
    }
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
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
                offset: const Offset(0, 2))
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
    Widget? trailing,
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
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
}