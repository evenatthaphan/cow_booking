import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/%E0%B8%B4bull_form.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BullListPage extends StatefulWidget {
  const BullListPage({super.key});

  @override
  State<BullListPage> createState() => _BullListPageState();
}

class _BullListPageState extends State<BullListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allBulls = [];
  List<Map<String, dynamic>> _filtered = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchBulls());
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _adminType =>
      Provider.of<DataAdmin>(context, listen: false).datauser.adminType.toString();

  // ── โหลดข้อมูล ─────────────────────────────────────────────────────────
  Future<void> _fetchBulls() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/bulls'),
        headers: {'admin-type': _adminType},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _allBulls = data.cast<Map<String, dynamic>>();
          _filtered = _allBulls;
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
      _filtered = _allBulls.where((b) {
        final name  = (b['bulls_name']  ?? '').toLowerCase();
        final breed = (b['bulls_breed'] ?? '').toLowerCase();
        return name.contains(q) || breed.contains(q);
      }).toList();
    });
  }

  // ── ลบพ่อพันธุ์ ──────────────────────────────────────────────────────────
  Future<void> _deleteBull(int bullId, String bullName) async {
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
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('ลบพ่อพันธุ์',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('ต้องการลบ "$bullName" ใช่หรือไม่?'),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
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
        _showSnackbar('ลบพ่อพันธุ์สำเร็จ', Colors.green);
        _fetchBulls();
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

  Future<void> _goToForm({Map<String, dynamic>? bull}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BullFormPage(bull: bull)),
    );
    if (result == true) _fetchBulls();
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
            Text('จัดการพ่อพันธุ์',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.green[900]),
            onPressed: () => _goToForm(),
            tooltip: 'เพิ่มพ่อพันธุ์',
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
                hintText: 'ค้นหาชื่อ หรือสายพันธุ์...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                        onPressed: () { _searchCtrl.clear(); _onSearch(); },
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

          // ── จำนวน ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text('ทั้งหมด ${_filtered.length} ตัว',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold)),
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
                            Icon(Icons.pets, size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text(
                              _searchCtrl.text.isNotEmpty
                                  ? 'ไม่พบผลการค้นหา'
                                  : 'ยังไม่มีข้อมูลพ่อพันธุ์',
                              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.green,
                        onRefresh: _fetchBulls,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _bullCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToForm(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มพ่อพันธุ์',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _bullCard(Map<String, dynamic> bull) {
    final bullId    = int.tryParse(bull['bulls_id'].toString()) ?? 0;
    final name      = bull['bulls_name']             ?? '-';
    final breed     = bull['bulls_breed']            ?? '-';
    final age       = bull['bulls_age'];
    final stock     = bull['total_stock']            ?? 0;
    final health    = bull['bulls_HealthStatus']     ?? '';
    final highlight = bull['bulls_characteristics']  ?? '';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🐂',
                    style: TextStyle(fontSize: 16, color: Colors.brown[700]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(breed,
                          style: TextStyle(
                              fontSize: 12, color: Colors.brown[600])),
                    ],
                  ),
                ),
                // badge stock
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_outlined,
                          size: 12, color: Colors.green[700]),
                      const SizedBox(width: 3),
                      Text('$stock โดส',
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

          // ── รายละเอียด ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (age != null)
                  _chip(Icons.cake_outlined, 'อายุ $age ปี', Colors.blue),
                if (health.isNotEmpty)
                  _chip(Icons.favorite_outline, health, Colors.red),
                if (highlight.isNotEmpty)
                  _chip(Icons.star_outline, highlight, Colors.orange),
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
                  onPressed: () => _goToForm(bull: bull),
                  icon: Icon(Icons.edit_outlined,
                      size: 14, color: Colors.green[700]),
                  label: Text('แก้ไข',
                      style: TextStyle(
                          fontSize: 13, color: Colors.green[700])),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _deleteBull(bullId, name),
                  icon: const Icon(Icons.delete_outline,
                      size: 14, color: Colors.red),
                  label: const Text('ลบ',
                      style: TextStyle(fontSize: 13, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: color),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}