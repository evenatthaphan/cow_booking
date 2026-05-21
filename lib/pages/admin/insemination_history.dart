import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class InseminationHistoryPage extends StatefulWidget {
  const InseminationHistoryPage({super.key});

  @override
  State<InseminationHistoryPage> createState() =>
      _InseminationHistoryPageState();
}

class _InseminationHistoryPageState extends State<InseminationHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;

  // แบ่งตาม bookings_status
  List<Map<String, dynamic>> _all       = [];
  List<Map<String, dynamic>> _pending   = [];
  List<Map<String, dynamic>> _accepted  = [];
  List<Map<String, dynamic>> _completed = [];
  List<Map<String, dynamic>> _rejected  = [];

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // filters
  String? _fromDate;
  String? _toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

  // ── fetch ────────────────────────────────────────────────
  Future<void> _fetchHistory() async {
    if (!mounted) return;
    final auth = context.read<DataAdmin>();
    setState(() => _isLoading = true);

    try {
      final params = <String, String>{};
      if (_fromDate != null) params['from_date'] = _fromDate!;
      if (_toDate != null)   params['to_date']   = _toDate!;

      final uri = Uri.parse('$apiEndpoint/admin/inseminations')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'admin-type': auth.datauser.adminType.toString(),
      });

      if (res.statusCode == 200) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        if (list.isNotEmpty) debugPrint('SAMPLE: ${list[0]}');
        setState(() {
          _all       = list;
          _pending   = list.where((r) => r['bookings_status'] == 'pending').toList();
          _accepted  = list.where((r) => r['bookings_status'] == 'accepted').toList();
          _completed = list.where((r) => r['bookings_status'] == 'completed').toList();
          _rejected  = list.where((r) => r['bookings_status'] == 'rejected').toList();
        });
      } else if (res.statusCode == 403) {
        _showSnack('ไม่มีสิทธิ์เข้าถึง', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── search ───────────────────────────────────────────────
  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((r) {
      final vet    = (r['vetexperts_name'] ?? '').toLowerCase();
      final farmer = (r['farmers_name']    ?? '').toLowerCase();
      final bull   = (r['bulls_name']      ?? '').toLowerCase();
      return vet.contains(_searchQuery) ||
             farmer.contains(_searchQuery) ||
             bull.contains(_searchQuery);
    }).toList();
  }

  // ── date filter sheet ────────────────────────────────────
  void _showDateFilterSheet() {
    final fromCtrl = TextEditingController(text: _fromDate ?? '');
    final toCtrl   = TextEditingController(text: _toDate   ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('กรองตามวันที่',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800])),
                TextButton(
                  onPressed: () {
                    setState(() { _fromDate = null; _toDate = null; });
                    Navigator.pop(context);
                    _fetchHistory();
                  },
                  child: const Text('ล้างทั้งหมด',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dateField(fromCtrl, 'ตั้งแต่วันที่ (YYYY-MM-DD)'),
            const SizedBox(height: 12),
            _dateField(toCtrl, 'ถึงวันที่ (YYYY-MM-DD)'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fromDate = fromCtrl.text.trim().isEmpty ? null : fromCtrl.text.trim();
                    _toDate   = toCtrl.text.trim().isEmpty   ? null : toCtrl.text.trim();
                  });
                  Navigator.pop(context);
                  _fetchHistory();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('ค้นหา',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
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
      );

  // ── detail sheet ─────────────────────────────────────────
  void _showDetail(Map<String, dynamic> r) {
    final status = r['bookings_status'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),

              // status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _statusColor(status).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(status),
                        color: _statusColor(status), size: 20),
                    const SizedBox(width: 8),
                    Text(_statusLabel(status),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _statusColor(status))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // ผู้เกี่ยวข้อง
              _detailLabel('ผู้เกี่ยวข้อง'),
              _detailRow(Icons.medical_services_outlined,
                  'สัตวบาล', r['vetexperts_name']?.toString() ?? '-'),
              _detailRow(Icons.agriculture,
                  'เกษตรกร', r['farmers_name']?.toString() ?? '-'),
              _detailRow(Icons.pets, 'พ่อพันธุ์',
                  [r['bulls_name'], r['bulls_breed']]
                      .where((s) => s != null && s.toString().isNotEmpty)
                      .map((s) => s.toString())
                      .join(' · ')
                      .let((s) => s.isNotEmpty ? s : '-')),
              const SizedBox(height: 12),

              // ตารางนัด
              _detailLabel('ตารางนัด'),
              _detailRow(Icons.calendar_today_outlined,
                  'วันที่นัด', _formatDate(r['schedule_date'])),
              _detailRow(Icons.access_time_outlined,
                  'เวลานัด', r['schedule_time']?.toString() ?? '-'),
              const SizedBox(height: 12),

              // การจอง
              _detailLabel('ข้อมูลการจอง'),
              _detailRow(Icons.format_list_numbered,
                  'จำนวนโดส', r['bookings_dose']?.toString() ?? '-'),
              _detailRow(Icons.calendar_month_outlined,
                  'วันที่จอง', _formatDate(r['created_at'])),
              if ((r['bookings_vet_notes']?.toString() ?? '').isNotEmpty)
                _detailRow(Icons.notes_outlined,
                    'หมายเหตุ vet', r['bookings_vet_notes'].toString()),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────
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

  String _formatDate(dynamic val) {
    if (val == null) return '-';
    try {
      final dt = DateTime.parse(val.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return val.toString();
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':   return 'รอดำเนินการ';
      case 'accepted':  return 'รับงานแล้ว';
      case 'completed': return 'เสร็จสิ้น';
      case 'rejected':  return 'ปฏิเสธ';
      default:          return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return Colors.orange;
      case 'accepted':  return Colors.blue;
      case 'completed': return Colors.green;
      case 'rejected':  return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':   return Icons.hourglass_empty;
      case 'accepted':  return Icons.thumb_up_outlined;
      case 'completed': return Icons.check_circle_outline;
      case 'rejected':  return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  bool get _hasDateFilter => _fromDate != null || _toDate != null;

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final allList       = _applySearch(_all);
    final pendingList   = _applySearch(_pending);
    final acceptedList  = _applySearch(_accepted);
    final completedList = _applySearch(_completed);
    final rejectedList  = _applySearch(_rejected);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ประวัติการผสมเทียม',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.date_range_outlined),
                tooltip: 'กรองตามวันที่',
                onPressed: _showDateFilterSheet,
              ),
              if (_hasDateFilter)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: 'ทั้งหมด (${allList.length})'),
            _statusTab('รอ',      pendingList.length,   Colors.orange),
            _statusTab('รับงาน', acceptedList.length,  Colors.blue),
            _statusTab('เสร็จ',  completedList.length, Colors.green),
            _statusTab('ปฏิเสธ', rejectedList.length,  Colors.red),
          ],
        ),
      ),
      body: Column(
        children: [
          // search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาสัตวบาล, เกษตรกร, พ่อพันธุ์...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // date filter chips
          if (_hasDateFilter)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_fromDate != null)
                    _chip('ตั้งแต่: $_fromDate',
                        () { setState(() => _fromDate = null); _fetchHistory(); }),
                  if (_toDate != null)
                    _chip('ถึง: $_toDate',
                        () { setState(() => _toDate = null); _fetchHistory(); }),
                ],
              ),
            ),

          // summary
          if (!_isLoading && _all.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _summaryChip('รอ',      _pending.length,   Colors.orange),
                    const SizedBox(width: 6),
                    _summaryChip('รับงาน', _accepted.length,  Colors.blue),
                    const SizedBox(width: 6),
                    _summaryChip('เสร็จ',  _completed.length, Colors.green),
                    const SizedBox(width: 6),
                    _summaryChip('ปฏิเสธ', _rejected.length,  Colors.red),
                    const SizedBox(width: 12),
                    if (_completed.isNotEmpty || _rejected.isNotEmpty)
                      Builder(builder: (_) {
                        final total = _completed.length + _rejected.length;
                        final rate  = total > 0
                            ? (_completed.length / total * 100)
                                .toStringAsFixed(1)
                            : '0.0';
                        return Text(
                          'สำเร็จ $rate%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        );
                      }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 6),

          // tabs
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _historyList(allList),
                      _historyList(pendingList),
                      _historyList(acceptedList),
                      _historyList(completedList),
                      _historyList(rejectedList),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Tab _statusTab(String label, int count, Color color) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  Widget _chip(String label, VoidCallback onRemove) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: onRemove,
          backgroundColor: Colors.green[50],
          side: BorderSide(color: Colors.green[200]!),
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget _summaryChip(String label, int count, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text('$label $count',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      );

  Widget _historyList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text('ไม่พบข้อมูล', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _historyCard(list[i]),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> r) {
    final status      = r['bookings_status'] ?? '';
    final statusColor = _statusColor(status);
    final statusIcon  = _statusIcon(status);
    final statusLabel = _statusLabel(status);

    final bullText = [r['bulls_name'], r['bulls_breed']]
        .where((s) => s != null && s.toString().isNotEmpty)
        .join(' · ');

    return GestureDetector(
      onTap: () => _showDetail(r),
      child: Container(
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
              // row 1: วันที่นัด + status
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(r['schedule_date'])}'
                    '${r['schedule_time'] != null ? '  ${r['schedule_time']}' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusLabel,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),

              // vet + farmer
              Row(
                children: [
                  Expanded(
                    child: _cardInfo(
                      Icons.medical_services_outlined,
                      'สัตวบาล',
                      r['vetexperts_name']?.toString() ?? '-',
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _cardInfo(
                      Icons.agriculture,
                      'เกษตรกร',
                      r['farmers_name']?.toString() ?? '-',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // bull + dose
              Row(
                children: [
                  Expanded(
                    child: _cardInfo(
                      Icons.pets,
                      'พ่อพันธุ์',
                      bullText.isNotEmpty ? bullText : '-',
                      Colors.brown,
                    ),
                  ),
                  _cardInfo(
                    Icons.water_drop_outlined,
                    'โดส',
                    r['bookings_dose']?.toString() ?? '-',
                    Colors.indigo,
                  ),
                ],
              ),

              // vet notes
              if ((r['bookings_vet_notes'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r['bookings_vet_notes'],
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardInfo(IconData icon, String label, String value, Color color) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
                Text(
                    value.isNotEmpty ? value : '-',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );

  Widget _detailLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
      );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

extension StringLet on String {
  T let<T>(T Function(String) block) => block(this);
}