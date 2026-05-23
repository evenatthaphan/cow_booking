import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminFormPage extends StatefulWidget {
  /// ถ้า admin == null → โหมดเพิ่ม, ถ้ามีข้อมูล → โหมดแก้ไข
  final Map<String, dynamic>? admin;

  const AdminFormPage({super.key, this.admin});

  @override
  State<AdminFormPage> createState() => _AdminFormPageState();
}

class _AdminFormPageState extends State<AdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading  = false;
  bool _obscurePwd = true;

  // Controllers
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passwordCtrl= TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  int _selectedType  = 3; // default = admin

  bool get _isEdit => widget.admin != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final a = widget.admin!;
      _nameCtrl.text    = a['admins_name']        ?? '';
      _emailCtrl.text   = a['admins_email']       ?? '';
      _phoneCtrl.text   = a['admins_phonenumber'] ?? '';
      _addressCtrl.text = a['admins_address']     ?? '';
      _selectedType     = a['admin_type']         ?? 3;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── submit ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    final auth      = context.read<DataAdmin>();
    final myType    = auth.datauser.adminType;
    final headers   = {
      'Content-Type': 'application/json',
      'admin-type':   myType.toString(),
    };

    setState(() => _isLoading = true);

    try {
      http.Response res;

      if (_isEdit) {
        // PUT /admin/update/:id
        final body = {
          'admins_name':        _nameCtrl.text.trim(),
          'admins_email':       _emailCtrl.text.trim(),
          'admins_phonenumber': _phoneCtrl.text.trim(),
          'admins_address':     _addressCtrl.text.trim(),
          'admin_type':         _selectedType,
        };
        res = await http.put(
          Uri.parse('$apiEndpoint/admin/update/${widget.admin!['admins_id']}'),
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        // POST /admin/create
        final body = {
          'admins_name':        _nameCtrl.text.trim(),
          'admins_email':       _emailCtrl.text.trim(),
          'admins_password':    _passwordCtrl.text,
          'admins_phonenumber': _phoneCtrl.text.trim(),
          'admins_address':     _addressCtrl.text.trim(),
          'admin_type':         _selectedType,
        };
        res = await http.post(
          Uri.parse('$apiEndpoint/admin/create'),
          headers: headers,
          body: jsonEncode(body),
        );
      }

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnack(data['message'] ?? 'บันทึกสำเร็จ');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context, true); // true = reload list
      } else {
        _showSnack(data['message'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final myType = context.read<DataAdmin>().datauser.adminType;

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
            Text(
              _isEdit ? 'แก้ไขผู้ดูแลระบบ' : 'เพิ่มผู้ดูแลระบบ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900]),
            ),
          ],
        ),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Avatar preview ───────────────────────────
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Card: ข้อมูลพื้นฐาน ─────────────────────
              _sectionCard(
                label: 'ข้อมูลพื้นฐาน',
                children: [
                  _buildField(
                    controller: _nameCtrl,
                    label: 'ชื่อผู้ใช้ (Username)',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อ' : null,
                    onChanged: (_) => setState(() {}), // อัป avatar
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'อีเมล',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                      if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                      return null;
                    },
                  ),
                  // รหัสผ่าน — แสดงเฉพาะโหมดเพิ่ม
                  if (!_isEdit) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePwd,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePwd
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscurePwd = !_obscurePwd),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                        if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว';
                        return null;
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // ── Card: ข้อมูลติดต่อ ──────────────────────
              _sectionCard(
                label: 'ข้อมูลติดต่อ',
                children: [
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'เบอร์โทรศัพท์',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _addressCtrl,
                    label: 'ที่อยู่',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Card: สิทธิ์ ─────────────────────────────
              _sectionCard(
                label: 'ระดับสิทธิ์',
                children: [
                  // Master (myType=1) เลือกได้ทุก type
                  // Super  (myType=2) เลือกได้เฉพาะ type=3
                  ...[ 
                    if (myType == 1) ...[
                      _typeRadio(1, 'Master Admin', 'ควบคุมระบบทั้งหมด',   Colors.purple),
                      _typeRadio(2, 'Super Admin',  'จัดการ admin และสมาชิก', Colors.orange),
                    ],
                    _typeRadio(3, 'Admin',        'จัดการสมาชิกและข้อมูล', Colors.green),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // ── ปุ่มบันทึก ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มผู้ดูแลระบบ',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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

  // ── Widgets helpers ──────────────────────────────────────

  Widget _sectionCard({required String label, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  letterSpacing: 0.4)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
      validator: validator,
    );
  }

  Widget _typeRadio(int value, String title, String subtitle, Color color) {
    return RadioListTile<int>(
      value: value,
      groupValue: _selectedType,
      onChanged: (v) => setState(() => _selectedType = v!),
      activeColor: color,
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}