import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/Animal_husbandry/bull_form_page.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VetBullListPage extends StatefulWidget {
  const VetBullListPage({super.key});

  @override
  State<VetBullListPage> createState() => _VetBullListPageState();
}

class _VetBullListPageState extends State<VetBullListPage> {
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

  Future<void> _fetchBulls() async {
    if (!mounted) return;
    final vetId = context.read<DataVetExpert>().datauser.id;
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/vet/vet-bulls/my/$vetId'),
      );
      if (res.statusCode == 200) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() {
          _allBulls = list;
          _filtered = list;
        });
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allBulls
          .where((b) =>
              (b['bulls_name'] ?? '').toLowerCase().contains(q) ||
              (b['bulls_breed'] ?? '').toLowerCase().contains(q) ||
              (b['frams_name'] ?? '').toLowerCase().contains(q))
          .toList();
    });
  }

  // ── Dialog แก้ไข stock + ราคา ─────────────────────────────────────────────
  void _showEditDialog(Map<String, dynamic> bull) {
    final stockCtrl = TextEditingController(
        text: bull['bulls_semen_stock']?.toString() ?? '0');
    final priceCtrl = TextEditingController(
        text: bull['bulls_price_per_dose']?.toString() ?? '0');
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.edit_outlined,
                      color: Colors.green[700], size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bull['bulls_name'] ?? '-',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(bull['bulls_breed'] ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                ctrl: stockCtrl,
                label: 'จำนวนโดสคงเหลือ',
                icon: Icons.science_outlined,
                keyboardType: TextInputType.number,
                suffix: 'โดส',
              ),
              const SizedBox(height: 14),
              _dialogField(
                ctrl: priceCtrl,
                label: 'ราคาต่อโดส',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                suffix: 'บาท',
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
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
                    onPressed: saving
                        ? null
                        : () async {
                            final stock = int.tryParse(stockCtrl.text) ?? -1;
                            final price = double.tryParse(priceCtrl.text) ?? -1;

                            if (stock <= 0 || stock > 10) {
                              _showSnack('จำนวนโดสต้องเป็นตัวเลข 1-10', isError: true);
                              return;
                            }
                            if (price <= 0) {
                              _showSnack('ราคาต่อโดสต้องมากกว่า 0', isError: true);
                              return;
                            }

                            setD(() => saving = true);
                            await _updateBull(
                              vetBullId: bull['vet_bulls_id'],
                              stock: stock,
                              price: price,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('บันทึก',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBull({
    required int vetBullId,
    required int stock,
    required double price,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$apiEndpoint/vet/vet-bulls/update/$vetBullId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bulls_semen_stock': stock,
          'bulls_price_per_dose': price,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _showSnack('อัพเดตสำเร็จ ✓');
        _fetchBulls();
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['error'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red : Colors.green,
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
                  'จัดการสต็อกวัวของคุณ',
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
      ),
      body: Column(
        children: [
          // ── Search ───────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อ, สายพันธุ์, ฟาร์ม...',
                hintStyle:
                    GoogleFonts.notoSansThai(color: Colors.grey, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: Colors.grey),
                        onPressed: () => _searchCtrl.clear())
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── จำนวน ──────────────────────────────────────────────────
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

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
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
                                  : 'ยังไม่มีวัวในสต็อก',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.green,
                        onRefresh: _fetchBulls,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _bullCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddBullStockPage()),
          );
          if (result == true) _fetchBulls();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มวัว',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _bullCard(Map<String, dynamic> bull) {
    final name = bull['bulls_name'] ?? '-';
    final breed = bull['bulls_breed'] ?? '-';
    final farm = bull['frams_name'] ?? 'ไม่ระบุฟาร์ม';
    final stock = bull['bulls_semen_stock'] ?? 0;
    final price = bull['bulls_price_per_dose'] ?? 0;
    final img1 = bull['bulls_image1'] as String?;

    final stockColor = (stock as int) > 5
        ? Colors.green
        : (stock > 0 ? Colors.orange : Colors.red);

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
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showEditDialog(bull),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── รูปภาพ ──────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: img1 != null && img1.isNotEmpty
                    ? Image.network(img1,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder())
                    : _imgPlaceholder(),
              ),
              const SizedBox(width: 12),

              // ── ข้อมูล ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(breed,
                        style:
                            TextStyle(fontSize: 12, color: Colors.brown[600])),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.home_work_outlined,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(farm,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // stock badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stockColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: stockColor.withOpacity(0.3)),
                          ),
                          child: Text('$stock โดส',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stockColor)),
                        ),
                        const SizedBox(width: 8),
                        // ราคา
                        Text('฿$price / โดส',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),

              // ── ปุ่มแก้ไข ────────────────────────────────────────────
              Icon(Icons.edit_outlined, color: Colors.green[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.pets, color: Colors.brown[200], size: 30),
      );

  Widget _dialogField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(icon, size: 20, color: Colors.green[600]),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF5F7F2),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green[400]!, width: 1.5)),
        ),
      );
}
