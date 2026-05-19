import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VetEditAddressPage extends StatefulWidget {
  const VetEditAddressPage({super.key});

  @override
  State<VetEditAddressPage> createState() => _VetEditAddressPageState();
}

class _VetEditAddressPageState extends State<VetEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _provinceCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _localityCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final vet = Provider.of<DataVetExpert>(context, listen: false).datauser;
    _provinceCtrl = TextEditingController(text: vet.province);
    _districtCtrl = TextEditingController(text: vet.district);
    _localityCtrl = TextEditingController(text: vet.locality);
    _addressCtrl  = TextEditingController(text: vet.vetExpertAddress);
  }

  @override
  void dispose() {
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _localityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final vetId = Provider.of<DataVetExpert>(context, listen: false).datauser.id;

      final response = await http.put(
        Uri.parse('$apiEndpoint/vetexpert/update-address/$vetId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vetexperts_province': _provinceCtrl.text.trim(),
          'vetexperts_district': _districtCtrl.text.trim(),
          'vetexperts_locality': _localityCtrl.text.trim(),
          'vetexperts_address':  _addressCtrl.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await Provider.of<DataVetExpert>(context, listen: false)
            .fetchVetById(vetId);
        _showSnackbar('บันทึกที่อยู่สำเร็จ ✓', Colors.green);
        Navigator.pop(context);
      } else {
        final body = jsonDecode(response.body);
        _showSnackbar('เกิดข้อผิดพลาด: ${body['error']}', Colors.red);
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
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('แก้ไขที่อยู่',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Icon header ───────────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on_outlined, size: 48, color: Colors.blue[700]),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('ระบุที่อยู่ของคุณหมอ',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),

              const SizedBox(height: 24),
              _sectionLabel('ที่อยู่'),
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
                _divider(),
                _inputField(
                  controller: _addressCtrl,
                  label: 'ที่อยู่ (บ้านเลขที่, หมู่, ถนน)',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
              ]),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('บันทึกที่อยู่',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),
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
              child: Icon(icon, size: 20, color: Colors.blue[600]),
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
