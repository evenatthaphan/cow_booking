import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/admin_change_password.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = false;

  // ── Controllers ───────────────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final admin = Provider.of<DataAdmin>(context, listen: false).datauser;
    _phoneCtrl.text = admin.adminsPhonenumber;
    _emailCtrl.text = admin.adminsEmail;
    _addressCtrl.text = admin.adminsAddress;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String get _adminType => Provider.of<DataAdmin>(context, listen: false)
      .datauser
      .adminType
      .toString();

  // ── บันทึกข้อมูล ──────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final adminId =
          Provider.of<DataAdmin>(context, listen: false).datauser.adminsId;

      final res = await http.put(
        Uri.parse('$apiEndpoint/admin/update-profile/$adminId'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': _adminType,
        },
        body: jsonEncode({
          'admins_phonenumber': _phoneCtrl.text.trim(),
          'admins_email': _emailCtrl.text.trim(),
          'admins_address': _addressCtrl.text.trim(),
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _showSnackbar('บันทึกข้อมูลสำเร็จ ✓', Colors.green);
      } else {
        final body = jsonDecode(res.body);
        _showSnackbar(body['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── ออกจากระบบ ────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('ออกจากระบบ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยกเลิก',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ออกจากระบบ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // clear data
    Provider.of<DataAdmin>(context, listen: false).clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    // ไปหน้า Login แทนที่ทุกหน้า
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<DataAdmin>(context).datauser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                  'โปรไฟล์ของฉัน',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[900],
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + ชื่อ + type ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      admin.adminsName.isNotEmpty
                          ? admin.adminsName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    admin.adminsName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      _adminTypeLabel(admin.adminType),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── ข้อมูลที่แก้ไขได้ ────────────────────────────────────
            _sectionLabel('ข้อมูลส่วนตัว'),
            _infoCard([
              _inputField(
                controller: _phoneCtrl,
                label: 'เบอร์โทรศัพท์',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _divider(),
              _inputField(
                controller: _emailCtrl,
                label: 'อีเมล',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _divider(),
              _inputField(
                controller: _addressCtrl,
                label: 'ที่อยู่',
                icon: Icons.home_outlined,
                maxLines: 2,
              ),
            ]),

            const SizedBox(height: 12),

            // ── ปุ่มบันทึก ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined,
                        color: Colors.white, size: 18),
                label: Text(
                  _isLoading ? 'กำลังบันทึก...' : 'บันทึกข้อมูล',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── การตั้งค่าบัญชี ───────────────────────────────────────
            _sectionLabel('การตั้งค่าบัญชี'),
            _menuCard([
              _menuItem(
                icon: Icons.lock_outline,
                iconColor: Colors.orange,
                label: 'เปลี่ยนรหัสผ่าน',
                subtitle: 'อัพเดตรหัสผ่านของคุณ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminChangePasswordPage(isFirstLogin: false),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── ออกจากระบบ ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                label: const Text(
                  'ออกจากระบบ',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _adminTypeLabel(int type) {
    switch (type) {
      case 1:
        return 'Master Admin';
      case 2:
        return 'Super Admin';
      default:
        return 'Admin';
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

  Widget _divider() =>
      const Divider(height: 1, indent: 52, color: Color(0xFFEEEEEE));

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Icon(icon, size: 20, color: Colors.green[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
}
