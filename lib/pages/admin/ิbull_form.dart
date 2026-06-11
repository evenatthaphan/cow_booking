import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BullFormPage extends StatefulWidget {
  final Map<String, dynamic>? bull;

  const BullFormPage({super.key, this.bull});

  @override
  State<BullFormPage> createState() => _BullFormPageState();
}

class _BullFormPageState extends State<BullFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  late TextEditingController _nameCtrl;
  late TextEditingController _breedCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _characterCtrl;
  late TextEditingController _contestCtrl;
  late TextEditingController _healthCtrl;

  List<Map<String, dynamic>> _farms = [];
  int? _selectedFarmId;
  bool _isFarmLoading = true;

  bool _isLoading = false;

  bool get isEdit => widget.bull != null;

  String get _adminType => Provider.of<DataAdmin>(context, listen: false)
      .datauser
      .adminType
      .toString();

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    final bull = widget.bull;
    _nameCtrl =
        TextEditingController(text: bull?['bulls_name']?.toString() ?? '');
    _breedCtrl =
        TextEditingController(text: bull?['bulls_breed']?.toString() ?? '');
    _ageCtrl =
        TextEditingController(text: bull?['bulls_age']?.toString() ?? '');
    _characterCtrl = TextEditingController(
        text: bull?['bulls_characteristics']?.toString() ?? '');
    _contestCtrl = TextEditingController(
        text: bull?['bulls_contest_records']?.toString() ?? '');
    _healthCtrl = TextEditingController(
        text: bull?['bulls_HealthStatus']?.toString() ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFarms());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _characterCtrl.dispose();
    _contestCtrl.dispose();
    _healthCtrl.dispose();
    super.dispose();
  }

  // API
  

  Future<void> _fetchFarms() async {
    setState(() => _isFarmLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/farms'),
        headers: {'admin-type': _adminType},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final farms = data.cast<Map<String, dynamic>>();

        int? preselect;
        if (widget.bull?['ref_farm_id'] != null) {
          final refId = int.tryParse(widget.bull!['ref_farm_id'].toString());
          final exists = farms.any(
            (f) => int.tryParse(f['frams_id'].toString()) == refId,
          );
          if (exists) preselect = refId;
        }

        setState(() {
          _farms = farms;
          _selectedFarmId = preselect;
        });
      }
    } catch (_) {
      _showSnackBar('ไม่สามารถโหลดข้อมูลฟาร์มได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isFarmLoading = false);
    }
  }

  Future<void> _saveBull() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmId == null) {
      _showSnackBar('กรุณาเลือกฟาร์ม', Colors.orange);
      return;
    }
    setState(() => _isLoading = true);

    try {
      final ageText = _ageCtrl.text.trim();
      final body = {
        "bulls_name": _nameCtrl.text.trim(),
        "bulls_breed": _breedCtrl.text.trim(),
        if (ageText.isNotEmpty) "bulls_age": int.tryParse(ageText),
        "bulls_characteristics": _characterCtrl.text.trim(),
        "bulls_contest_records": _contestCtrl.text.trim(),
        "bulls_HealthStatus": _healthCtrl.text.trim(),
        "ref_farm_id": _selectedFarmId,
      };

      http.Response res;

      if (isEdit) {
        final bullId = widget.bull!['bulls_id'];
        res = await http.put(
          Uri.parse('$apiEndpoint/admin/bulls/update/$bullId'),
          headers: {
            'Content-Type': 'application/json',
            'admin-type': _adminType
          },
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse('$apiEndpoint/admin/bulls/create'),
          headers: {
            'Content-Type': 'application/json',
            'admin-type': _adminType
          },
          body: jsonEncode(body),
        );
      }

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackBar(
          isEdit ? 'แก้ไขข้อมูลสำเร็จ ✓' : 'เพิ่มพ่อพันธุ์สำเร็จ ✓',
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(res.body);
        _showSnackBar(data['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (_) {
      _showSnackBar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBull() async {
    final bullId = widget.bull?['bulls_id'];

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
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('ลบพ่อพันธุ์',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
            'ต้องการลบ "${_nameCtrl.text}" ใช่หรือไม่?\nการดำเนินการนี้ไม่สามารถยกเลิกได้'),
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

    try {
      final res = await http.delete(
        Uri.parse('$apiEndpoint/admin/bulls/delete/$bullId'),
        headers: {'admin-type': _adminType},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _showSnackBar('ลบข้อมูลสำเร็จ', Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnackBar('ลบข้อมูลไม่สำเร็จ', Colors.red);
      }
    } catch (_) {
      _showSnackBar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI helpers
  // ══════════════════════════════════════════════════════════════════════════

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.green[700]),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.green[100], thickness: 1)),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) {
            return 'กรุณากรอก $label';
          }
          if (validator != null) {
            return validator(v);
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Icon(icon, size: 18, color: Colors.green[600]),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _farmDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        value: _selectedFarmId,
        validator: (v) => v == null ? 'กรุณาเลือกฟาร์ม' : null,
        onChanged: (v) => setState(() => _selectedFarmId = v),
        decoration: InputDecoration(
          labelText: 'ฟาร์ม',
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
          prefixIcon: Icon(Icons.agriculture_outlined,
              size: 18, color: Colors.green[600]),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: _isFarmLoading
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.green[400]),
                  ),
                )
              : null,
        ),
        hint: Text(
          _isFarmLoading ? 'กำลังโหลด...' : 'เลือกฟาร์ม',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        isExpanded: true,
        icon: _isFarmLoading
            ? const SizedBox.shrink()
            : Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
        items: _farms.map((farm) {
          final id = int.tryParse(farm['frams_id'].toString()) ?? 0;
          final name = farm['frams_name']?.toString() ?? '-';
          return DropdownMenuItem<int>(
            value: id,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.location_on_outlined,
                      size: 13, color: Colors.green[600]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════════════════════════

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
              isEdit ? 'แก้ไขข้อมูลพ่อพันธุ์' : 'เพิ่มพ่อพันธุ์',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900]),
            ),
          ],
        ),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: _isLoading ? null : _deleteBull,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 18),
              ),
              tooltip: 'ลบพ่อพันธุ์',
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header card ────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[100]!, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🐂',
                        style:
                            TextStyle(fontSize: 18, color: Colors.brown[700]),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? 'แก้ไขข้อมูลพ่อพันธุ์'
                                : 'ข้อมูลพ่อพันธุ์ใหม่',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEdit
                                ? 'แก้ไขและบันทึกข้อมูลที่ต้องการเปลี่ยน'
                                : 'กรอกข้อมูลให้ครบถ้วนเพื่อเพิ่มพ่อพันธุ์',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Section: ข้อมูลพื้นฐาน ─────────────────────────────────
              _sectionHeader('ข้อมูลพื้นฐาน', Icons.info_outline),
              _field(
                label: 'ชื่อพ่อพันธุ์',
                controller: _nameCtrl,
                icon: Icons.pets,
                hint: 'เช่น ไทยโฮลสไตน์ หมายเลข 1',
              ),
              _field(
                label: 'สายพันธุ์',
                controller: _breedCtrl,
                icon: Icons.category_outlined,
                hint: 'เช่น โฮลสไตน์ฟรีเชี่ยน',
              ),
              _field(
                label: 'อายุ (ปี)',
                controller: _ageCtrl,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                required: false,
                hint: 'เช่น 3',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final age = int.tryParse(value.trim());
                  if (age == null) return 'โปรดกรอกตัวเลขในช่องอายุ';
                  if (age <= 0) return 'อายุต้องมากกว่า 0';
                  return null;
                },
              ),

              // ── Section: ฟาร์ม ─────────────────────────────────────────
              _sectionHeader('ฟาร์ม', Icons.agriculture_outlined),
              _farmDropdown(),

              // ── Section: ลักษณะ & ประวัติ ──────────────────────────────
              _sectionHeader('ลักษณะ & ประวัติ', Icons.auto_awesome_outlined),
              _field(
                label: 'สถานะสุขภาพ',
                controller: _healthCtrl,
                icon: Icons.monitor_heart_outlined,
                hint: 'เช่น แข็งแรง / อยู่ระหว่างรักษา',
              ),
              _field(
                label: 'ลักษณะเด่น',
                controller: _characterCtrl,
                icon: Icons.star_outline,
                hint: 'เช่น ให้ผลผลิตน้ำเชื้อสูง',
              ),

              // ── Section: ประวัติการประกวด ──────────────────────────────
              _sectionHeader('ประวัติการประกวด', Icons.history_edu_outlined),
              _field(
                label: 'ประวัติการประกวด',
                controller: _contestCtrl,
                icon: Icons.emoji_events_outlined,
                maxLines: 2,
                required: false,
                hint: 'เช่น ชนะเลิศงานแสดงวัวปี 2567',
              ),

              const SizedBox(height: 8),

              // ── Save button ────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBull,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text('กำลังบันทึก...',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มพ่อพันธุ์',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
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
}
