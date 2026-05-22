import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/farm_form.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FarmListPage extends StatefulWidget {
  const FarmListPage({super.key});

  @override
  State<FarmListPage> createState() => _FarmListPageState();
}

class _FarmListPageState extends State<FarmListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allFarms  = [];
  List<Map<String, dynamic>> _filtered  = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFarms());
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── โหลดข้อมูล ─────────────────────────────────────────────────────────
  Future<void> _fetchFarms() async {
    setState(() => _isLoading = true);
    try {
      final adminType = Provider.of<DataAdmin>(context, listen: false)
          .datauser.adminType.toString();

      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/farms'),
        headers: {'admin-type': adminType},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _allFarms = data.cast<Map<String, dynamic>>();
          _filtered = _allFarms;
        });
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถโหลดข้อมูลได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── ค้นหา ───────────────────────────────────────────────────────────────
  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allFarms.where((f) {
        final name     = (f['farmers_name']     ?? '').toLowerCase();
        final province = (f['farmers_province'] ?? '').toLowerCase();
        final district = (f['farmers_district'] ?? '').toLowerCase();
        return name.contains(q) || province.contains(q) || district.contains(q);
      }).toList();
    });
  }

  // ── ลบฟาร์ม ─────────────────────────────────────────────────────────────
  Future<void> _deleteFarm(int farmId, String farmName) async {
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
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('ลบฟาร์ม', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('ต้องการลบ "$farmName" ใช่หรือไม่?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ลบ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final adminType = Provider.of<DataAdmin>(context, listen: false)
          .datauser.adminType.toString();

      final res = await http.delete(
        Uri.parse('$apiEndpoint/admin/farms/delete/$farmId'),
        headers: {'admin-type': adminType},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _showSnackbar('ลบฟาร์มสำเร็จ', Colors.green);
        _fetchFarms();
      } else {
        final body = jsonDecode(res.body);
        _showSnackbar(body['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
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

  // ── ไปหน้า form ──────────────────────────────────────────────────────────
  Future<void> _goToForm({Map<String, dynamic>? farm}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FarmFormPage(farm: farm)),
    );
    if (result == true) _fetchFarms();
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
            Text('จัดการฟาร์ม',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.green[900]),
            onPressed: () => _goToForm(),
            tooltip: 'เพิ่มฟาร์ม',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อฟาร์ม, จังหวัด, อำเภอ...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── จำนวนผลลัพธ์ ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text('ทั้งหมด ${_filtered.length} ฟาร์ม',
                    style: TextStyle(fontSize: 13, color: Colors.green[800], fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // ── รายการ ───────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home_work_outlined, size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text(
                              _searchCtrl.text.isNotEmpty
                                  ? 'ไม่พบผลการค้นหา'
                                  : 'ยังไม่มีข้อมูลฟาร์ม',
                              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.green,
                        onRefresh: _fetchFarms,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) =>
                              _farmCard(_filtered[index]),
                        ),
                      ),
          ),
        ],
      ),

      // ── FAB เพิ่มฟาร์ม ───────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToForm(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มฟาร์ม', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _farmCard(Map<String, dynamic> farm) {
    final farmId   = int.tryParse(farm['frams_id'].toString()) ?? 0;
    final name     = farm['frams_name']  ?? '-';
    final province = farm['frams_province'] ?? '';
    final district = farm['frams_district'] ?? '';
    final locality = farm['frams_locality'] ?? '';
    final bulls    = farm['total_bulls']   ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.home_work_outlined,
                      size: 20, color: Colors.green[700]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                // badge จำนวนวัว
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, size: 12, color: Colors.green[700]),
                      const SizedBox(width: 3),
                      Text('$bulls ตัว',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── ที่อยู่ ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [locality, district, province]
                        .where((s) => s.isNotEmpty)
                        .join(', '),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── ปุ่ม ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _goToForm(farm: farm),
                  icon: Icon(Icons.edit_outlined, size: 14, color: Colors.green[700]),
                  label: Text('แก้ไข',
                      style: TextStyle(fontSize: 13, color: Colors.green[700])),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteFarm(farmId, name),
                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                  label: const Text('ลบ',
                      style: TextStyle(fontSize: 13, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}