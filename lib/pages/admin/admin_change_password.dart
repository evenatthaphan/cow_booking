import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/admin_dashbord_page.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminChangePasswordPage extends StatefulWidget {
  // isFirstLogin = true → บังคับเปลี่ยน ออกไม่ได้
  // isFirstLogin = false → เปลี่ยนเองจากโปรไฟล์ ออกได้
  final bool isFirstLogin;

  const AdminChangePasswordPage({super.key, this.isFirstLogin = true});

  @override
  State<AdminChangePasswordPage> createState() =>
      _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState extends State<AdminChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConf = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final adminId =
          Provider.of<DataAdmin>(context, listen: false).datauser.adminsId;

      final response = await http.put(
        Uri.parse('$apiEndpoint/admin/admin/change-password/$adminId'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': Provider.of<DataAdmin>(context, listen: false)
              .datauser
              .adminType
              .toString(),
        },
        body: jsonEncode({
          'old_password': _oldPassCtrl.text,
          'new_password': _newPassCtrl.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // อัพเดต mustChangePassword ใน local
        final admin = Provider.of<DataAdmin>(context, listen: false).datauser;
        Provider.of<DataAdmin>(context, listen: false).setDataUser(
          admin.copyWith(mustChangePassword: 0),
        );

        _showSnackbar('เปลี่ยนรหัสผ่านสำเร็จ ✓', Colors.green);

        if (widget.isFirstLogin) {
          // ไปหน้า Dashboard แทนที่ทุกหน้า
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
            (route) => false,
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        final body = jsonDecode(response.body);
        _showSnackbar(body['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // ถ้าบังคับเปลี่ยน ไม่ให้กดย้อนกลับได้
        automaticallyImplyLeading: !widget.isFirstLogin,
        leading: widget.isFirstLogin
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.green[900]),
                onPressed: () => Navigator.pop(context),
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
            Text(
              widget.isFirstLogin ? 'ตั้งรหัสผ่านใหม่' : 'เปลี่ยนรหัสผ่าน',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900]),
            ),
          ],
        ),
      ),
      // ป้องกัน back gesture บน iOS ถ้าเป็นครั้งแรก
      body: PopScope(
        canPop: !widget.isFirstLogin,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner แจ้งเตือน (เฉพาะครั้งแรก) ───────────────────
                if (widget.isFirstLogin) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange[700], size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ต้องเปลี่ยนรหัสผ่านก่อนใช้งาน',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800])),
                              const SizedBox(height: 2),
                              Text('กรุณาตั้งรหัสผ่านใหม่เพื่อความปลอดภัย',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.orange[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Icon ─────────────────────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline,
                        size: 48, color: Colors.orange[700]),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('กรอกรหัสผ่านเดิมและรหัสผ่านใหม่',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ),

                const SizedBox(height: 24),

                // ── Form ─────────────────────────────────────────────────
                _sectionLabel('รหัสผ่าน'),
                _infoCard([
                  _passField(
                    controller: _oldPassCtrl,
                    label: 'รหัสผ่านเดิม',
                    show: _showOld,
                    onToggle: () => setState(() => _showOld = !_showOld),
                    validator: (v) =>
                        v!.isEmpty ? 'กรุณากรอกรหัสผ่านเดิม' : null,
                  ),
                  _divider(),
                  _passField(
                    controller: _newPassCtrl,
                    label: 'รหัสผ่านใหม่',
                    show: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    validator: (v) {
                      if (v!.isEmpty) return 'กรุณากรอกรหัสผ่านใหม่';
                      if (v.length < 8)
                        return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                      if (v == _oldPassCtrl.text)
                        return 'รหัสผ่านใหม่ต้องไม่เหมือนเดิม';
                      return null;
                    },
                  ),
                  _divider(),
                  _passField(
                    controller: _confPassCtrl,
                    label: 'ยืนยันรหัสผ่านใหม่',
                    show: _showConf,
                    onToggle: () => setState(() => _showConf = !_showConf),
                    validator: (v) {
                      if (v!.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                      if (v != _newPassCtrl.text) return 'รหัสผ่านไม่ตรงกัน';
                      return null;
                    },
                  ),
                ]),

                const SizedBox(height: 16),

                // ── เงื่อนไขรหัสผ่าน ──────────────────────────────────
                _infoCard([
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('เงื่อนไขรหัสผ่าน',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800])),
                        const SizedBox(height: 8),
                        _requirement('อย่างน้อย 8 ตัวอักษร'),
                        _requirement('ต้องไม่เหมือนรหัสผ่านเดิม'),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 32),

                // ── ปุ่มบันทึก ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.isFirstLogin
                                ? 'ตั้งรหัสผ่านและเข้าสู่ระบบ'
                                : 'เปลี่ยนรหัสผ่าน',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  Widget _passField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 20, color: Colors.orange[600]),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: !show,
                validator: validator,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(show ? Icons.visibility_off : Icons.visibility,
                        size: 18, color: Colors.grey),
                    onPressed: onToggle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _requirement(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 14, color: Colors.green[600]),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
}
