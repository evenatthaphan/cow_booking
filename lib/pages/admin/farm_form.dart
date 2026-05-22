import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FarmFormPage extends StatefulWidget {
  final Map<String, dynamic>? farm;
  const FarmFormPage({super.key, this.farm});

  @override
  State<FarmFormPage> createState() => _FarmFormPageState();
}

class _FarmFormPageState extends State<FarmFormPage> {
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading  = false;
  bool _isDeleting = false;

  bool get _isEdit => widget.farm != null;

  final _nameCtrl     = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text     = widget.farm!['frams_name']     ?? '';
      _addressCtrl.text  = widget.farm!['frams_address']  ?? '';
      _provinceCtrl.text = widget.farm!['frams_province'] ?? '';
      _districtCtrl.text = widget.farm!['frams_district'] ?? '';
      _localityCtrl.text = widget.farm!['frams_locality'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _localityCtrl.dispose();
    super.dispose();
  }

  String get _adminType =>
      Provider.of<DataAdmin>(context, listen: false).datauser.adminType.toString();

  // ── บันทึก ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final body = {
        'frams_name':     _nameCtrl.text.trim(),
        'frams_address':  _addressCtrl.text.trim(),
        'frams_province': _provinceCtrl.text.trim(),
        'frams_district': _districtCtrl.text.trim(),
        'frams_locality': _localityCtrl.text.trim(),
      };

      final http.Response res;

      if (_isEdit) {
        final farmId = int.tryParse(widget.farm!['frams_id'].toString()) ?? 0;
        //final farmId = widget.farm!['frams_id'];
        res = await http.put(
          Uri.parse('$apiEndpoint/admin/farms/update/$farmId'),
          headers: {'Content-Type': 'application/json', 'admin-type': _adminType},
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse('$apiEndpoint/admin/farms/create'),
          headers: {'Content-Type': 'application/json', 'admin-type': _adminType},
          body: jsonEncode(body),
        );
      }

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackbar(
          _isEdit ? 'แก้ไขข้อมูลฟาร์มสำเร็จ ✓' : 'เพิ่มฟาร์มสำเร็จ ✓',
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(res.body);
        _showSnackbar(data['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── ลบฟาร์ม ──────────────────────────────────────────────────────────────
  Future<void> _delete() async {
    final farmId   = int.tryParse(widget.farm!['frams_id'].toString()) ?? 0;
    final farmName = widget.farm!['frams_name'] ?? 'ฟาร์มนี้';
    // final farmId   = widget.farm!['frams_id'];
    // final farmName = widget.farm!['frams_name'] ?? 'ฟาร์มนี้';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('ลบฟาร์ม',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('ต้องการลบ "$farmName" ใช่หรือไม่?\n\nฟาร์มจะถูกลบถาวรและไม่สามารถกู้คืนได้'),
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
                  child: const Text('ลบ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isDeleting = true);

    try {
      final res = await http.delete(
        Uri.parse('$apiEndpoint/admin/farms/delete/$farmId'),
        headers: {'admin-type': _adminType},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _showSnackbar('ลบฟาร์มสำเร็จ', Colors.green);
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(res.body);
        // กรณีมีวัวอยู่ในฟาร์ม
        final totalBulls = data['total_bulls'];
        _showSnackbar(
          totalBulls != null
              ? '${data['error']} ($totalBulls ตัว)'
              : data['error'] ?? 'เกิดข้อผิดพลาด',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
              _isEdit ? 'แก้ไขข้อมูลฟาร์ม' : 'เพิ่มฟาร์มใหม่',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
          ],
        ),
        // ── ปุ่มลบใน AppBar (เฉพาะโหมดแก้ไข) ──────────────────────────
        actions: _isEdit
            ? [
                _isDeleting
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        tooltip: 'ลบฟาร์ม',
                        onPressed: _delete,
                      ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Icon Header ───────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.home_work_outlined,
                      size: 48, color: Colors.green[700]),
                ),
              ),
              const SizedBox(height: 20),

              // ── ข้อมูลฟาร์ม ──────────────────────────────────────────
              _sectionLabel('ข้อมูลฟาร์ม'),
              _infoCard([
                _inputField(
                  controller: _nameCtrl,
                  label: 'ชื่อเจ้าของฟาร์ม / ชื่อฟาร์ม',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อฟาร์ม' : null,
                ),
                _divider(),
                _inputField(
                  controller: _addressCtrl,
                  label: 'ที่อยู่ (บ้านเลขที่, หมู่, ถนน)',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
              ]),

              const SizedBox(height: 16),

              // ── ที่ตั้ง ───────────────────────────────────────────────
              _sectionLabel('ที่ตั้ง'),
              _infoCard([
                _inputField(
                  controller: _provinceCtrl,
                  label: 'จังหวัด',
                  icon: Icons.location_city_outlined,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกจังหวัด' : null,
                ),
                _divider(),
                _inputField(
                  controller: _districtCtrl,
                  label: 'อำเภอ',
                  icon: Icons.map_outlined,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกอำเภอ' : null,
                ),
                _divider(),
                _inputField(
                  controller: _localityCtrl,
                  label: 'ตำบล',
                  icon: Icons.place_outlined,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกตำบล' : null,
                ),
              ]),

              const SizedBox(height: 32),

              // ── ปุ่มบันทึก ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(_isEdit ? Icons.save_outlined : Icons.add,
                          color: Colors.white, size: 20),
                  label: Text(
                    _isLoading
                        ? 'กำลังบันทึก...'
                        : _isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มฟาร์ม',
                    style: const TextStyle(
                        fontSize: 16,
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

              const SizedBox(height: 24),
            ],
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
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
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                validator: validator,
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
}