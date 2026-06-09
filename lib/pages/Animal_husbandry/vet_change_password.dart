import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VetChangePasswordPage extends StatefulWidget {
  const VetChangePasswordPage({super.key});

  @override
  State<VetChangePasswordPage> createState() => _VetChangePasswordPageState();
}

class _VetChangePasswordPageState extends State<VetChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _oldPassCtrl  = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _showOld  = false;
  bool _showNew  = false;
  bool _showConf = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
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
                'เปลี่ยนรหัสผ่าน',
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final vetId = Provider.of<DataVetExpert>(context, listen: false).datauser.id;

      final response = await http.put(
        Uri.parse('$apiEndpoint/vet/vetexpert/change-password/$vetId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'old_password': _oldPassCtrl.text,
          'new_password': _newPassCtrl.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackbar('เปลี่ยนรหัสผ่านสำเร็จ ✓', Colors.green);
        Navigator.pop(context);
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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Icon ─────────────────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline, size: 48, color: Colors.orange[700]),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('กรุณากรอกรหัสผ่านเดิมและรหัสผ่านใหม่',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),

              const SizedBox(height: 24),
              _sectionLabel('รหัสผ่าน'),
              _infoCard([
                _passField(
                  controller: _oldPassCtrl,
                  label: 'รหัสผ่านเดิม',
                  show: _showOld,
                  onToggle: () => setState(() => _showOld = !_showOld),
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกรหัสผ่านเดิม' : null,
                ),
                _divider(),
                _passField(
                  controller: _newPassCtrl,
                  label: 'รหัสผ่านใหม่',
                  show: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    if (v!.isEmpty) return 'กรุณากรอกรหัสผ่านใหม่';
                    if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('เปลี่ยนรหัสผ่าน',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: Colors.green[800], letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(height: 1, indent: 52, color: Color(0xFFEEEEEE));

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
}
