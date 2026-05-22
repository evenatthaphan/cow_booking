import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class InseminationHistoryPage extends StatefulWidget {
  const InseminationHistoryPage({super.key});

  @override
  State<InseminationHistoryPage> createState() => _InseminationHistoryPageState();
}

class _InseminationHistoryPageState extends State<InseminationHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<Map<String, dynamic>> _all      = [];
  List<Map<String, dynamic>> _pending  = [];
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _rejected = [];

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHistory());
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── ดึงข้อมูล ─────────────────────────────────────────────────────────────
  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final adminType =
          context.read<DataAdmin>().datauser.adminType.toString();

      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/inseminations'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': adminType,
        },
      );

      if (res.statusCode == 200) {
        final raw = jsonDecode(res.body) as List;

        // แปลงทุก field เป็น String ปลอดภัยตั้งแต่ต้น
        final list = raw.map((e) {
          final m = e as Map<String, dynamic>;
          return <String, dynamic>{
            'queue_bookings_id':  _str(m['queue_bookings_id']),
            'farmers_name':       _str(m['farmers_name'],       '-'),
            'vetexperts_name':    _str(m['vetexperts_name'],    '-'),
            'bulls_name':         _str(m['bulls_name'],         ''),
            'bulls_breed':        _str(m['bulls_breed'],        ''),
            'bookings_dose':      _str(m['bookings_dose'],      '-'),
            'bookings_status':    _str(m['bookings_status'],    ''),
            'bookings_vet_notes': _str(m['bookings_vet_notes'], ''),
            'schedule_date':      _str(m['schedule_date'],      ''),
            'schedule_time':      _str(m['schedule_time'],      ''),
            'created_at':         _str(m['created_at'],         ''),
          };
        }).toList();

        setState(() {
          _all      = list;
          _pending  = list.where((r) => r['bookings_status'] == 'pending').toList();
          _accepted = list.where((r) => r['bookings_status'] == 'accepted').toList();
          _rejected = list.where((r) => r['bookings_status'] == 'rejected').toList();
        });
      } else {
        _showSnack('โหลดข้อมูลไม่สำเร็จ: ${res.statusCode}', isError: true);
      }
    } catch (e) {
      debugPrint('FETCH ERROR: $e');
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── helper แปลงค่าเป็น String ───────────────────────────────────────────
  String _str(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    return val.toString();
  }

  // ── ค้นหา ─────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((r) {
      return (_str(r['vetexperts_name'])).toLowerCase().contains(_searchQuery) ||
             (_str(r['farmers_name'])).toLowerCase().contains(_searchQuery) ||
             (_str(r['bulls_name'])).toLowerCase().contains(_searchQuery);
    }).toList();
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

  String _formatDate(String val) {
    if (val.isEmpty) return '-';
    try {
      final dt = DateTime.parse(val);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return val;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':  return Colors.orange;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default:         return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':  return 'รอดำเนินการ';
      case 'accepted': return 'รับงานแล้ว';
      case 'rejected': return 'ปฏิเสธ';
      default:         return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allList      = _applySearch(_all);
    final pendingList  = _applySearch(_pending);
    final acceptedList = _applySearch(_accepted);
    final rejectedList = _applySearch(_rejected);

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
              'ประวัติการผสมเทียม',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── TabBar ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green[900],
              labelColor: Colors.green[900],
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: [
                Tab(text: 'ทั้งหมด (${allList.length})'),
                Tab(text: 'รอ (${pendingList.length})'),
                Tab(text: 'รับงาน (${acceptedList.length})'),
                Tab(text: 'ปฏิเสธ (${rejectedList.length})'),
              ],
            ),
          ),

          // ── Search ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาสัตวบาล, เกษตรกร, พ่อพันธุ์...',
                prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Summary ──────────────────────────────────────────────────
          if (!_isLoading && _all.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  _summaryChip('รอ',      _pending.length,  Colors.orange),
                  const SizedBox(width: 6),
                  _summaryChip('รับงาน', _accepted.length, Colors.green),
                  const SizedBox(width: 6),
                  _summaryChip('ปฏิเสธ', _rejected.length, Colors.red),
                ],
              ),
            ),

          // ── TabBarView ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(allList),
                      _buildList(pendingList),
                      _buildList(acceptedList),
                      _buildList(rejectedList),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text('$label $count',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
      );

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: Colors.grey),
            SizedBox(height: 8),
            Text('ไม่พบข้อมูล',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i]),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> r) {
    final status      = _str(r['bookings_status']);
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    final bullName  = _str(r['bulls_name']);
    final bullBreed = _str(r['bulls_breed']);
    final bullText  = [bullName, bullBreed]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    final vetNotes = _str(r['bookings_vet_notes']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── วันที่ + status ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_formatDate(_str(r['schedule_date']))}  ${_str(r['schedule_time'])}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
              ],
            ),

            const Divider(height: 14, color: Color(0xFFF0F0F0)),

            // ── ข้อมูล ───────────────────────────────────────────────
            _infoRow(Icons.medical_services_outlined, 'สัตวบาล',
                _str(r['vetexperts_name'], '-'), Colors.orange),
            const SizedBox(height: 6),
            _infoRow(Icons.agriculture, 'เกษตรกร',
                _str(r['farmers_name'], '-'), Colors.blue),
            const SizedBox(height: 6),
            _infoRow(Icons.pets, 'พ่อพันธุ์',
                bullText.isNotEmpty ? bullText : '-', Colors.brown),
            const SizedBox(height: 6),
            _infoRow(Icons.science_outlined, 'จำนวนโดส',
                '${_str(r['bookings_dose'], '-')} โดส', Colors.indigo),

            // ── หมายเหตุ ─────────────────────────────────────────────
            if (vetNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vetNotes,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}