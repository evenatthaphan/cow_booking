import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FarmerNotificationPage extends StatefulWidget {
  const FarmerNotificationPage({super.key});

  @override
  State<FarmerNotificationPage> createState() => _FarmerNotificationPageState();
}

class _FarmerNotificationPageState extends State<FarmerNotificationPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNotifications());
  }

  // ดึงข้อมูล 
  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    final farmerId =
        context.read<DataFarmers>().datauser.farmersId;
    setState(() => _isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/farmer/notifications/farmer/$farmerId'),
      );
      if (res.statusCode == 200) {
        final list =
            List<Map<String, dynamic>>.from(jsonDecode(res.body));
        setState(() => _notifications = list);
      }
    } catch (e) {
      debugPrint('fetch noti error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // อ่านทีละอัน
  Future<void> _markRead(int notiId, int index) async {
    if (_notifications[index]['is_read'] == 1) return;
    try {
      await http.put(
          Uri.parse('$apiEndpoint/farmer/notifications/read/$notiId'));
      setState(() => _notifications[index]['is_read'] = 1);
    } catch (_) {}
  }

  // อ่านทั้งหมด 
  Future<void> _markAllRead() async {
    final farmerId =
        context.read<DataFarmers>().datauser.farmersId;
    try {
      await http.put(Uri.parse(
          '$apiEndpoint/farmer/notifications/read-all/$farmerId'));
      setState(() {
        for (var n in _notifications) n['is_read'] = 1;
      });
    } catch (_) {}
  }

  int get _unreadCount =>
      _notifications.where((n) => n['is_read'] == 0).length;

  // config ตาม type
  Color _notiColor(String type) {
    switch (type) {
      case 'booking_accepted': return Colors.green;
      case 'booking_rejected': return Colors.red;
      case 'check_result':     return Colors.orange;
      default:                 return Colors.blue;
    }
  }

  IconData _notiIcon(String type) {
    switch (type) {
      case 'booking_accepted': return Icons.check_circle_outline;
      case 'booking_rejected': return Icons.cancel_outlined;
      case 'check_result':     return Icons.assignment_outlined;
      default:                 return Icons.notifications_outlined;
    }
  }

  String _formatDate(String? val) {
    if (val == null) return '';
    try {
      final dt = DateTime.parse(val).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
      if (diff.inHours < 24)   return '${diff.inHours} ชั่วโมงที่แล้ว';
      if (diff.inDays < 7)     return '${diff.inDays} วันที่แล้ว';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return val;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child: Text('🐄', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cow Booking',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1)),
              Text('การแจ้งเตือน',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 11, color: Colors.white70, height: 1.1)),
            ],
          ),
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllRead,
            child: Text('อ่านทั้งหมด',
                style: GoogleFonts.notoSansThai(
                    color: Colors.white70, fontSize: 13)),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: _green,
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) =>
                        _buildNotiCard(_notifications[i], i),
                  ),
                ),
      bottomNavigationBar: FarmerNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (value) {},
        screenSize: screenSize,
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('ยังไม่มีการแจ้งเตือน',
                style: GoogleFonts.notoSansThai(
                    fontSize: 15, color: Colors.grey[400])),
          ],
        ),
      );

  Widget _buildNotiCard(Map<String, dynamic> noti, int index) {
    final type    = (noti['noti_type']    ?? '') as String;
    final title   = (noti['noti_title']   ?? '') as String;
    final message = (noti['noti_message'] ?? '') as String;
    final date    = noti['created_at'] as String?;
    final isRead  = noti['is_read'] == 1;
    final notiId  = noti['noti_id'] as int? ?? 0;
    final color   = _notiColor(type);
    final icon    = _notiIcon(type);

    return GestureDetector(
      onTap: () {
        _markRead(notiId, index);
        // ถ้าเป็น check_result → แสดง dialog ให้กรอกผล
        if (type == 'check_result') {
          _showCheckResultDialog(noti);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? Colors.transparent : color.withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // เนื้อหา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 14,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: const Color(0xFF1A1A1A))),
                        ),
                        if (!isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(message,
                        style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(_formatDate(date),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                        if (type == 'check_result') ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange[200]!),
                            ),
                            child: Text('กรอกผล',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog กรอกผลการผสม 
  void _showCheckResultDialog(Map<String, dynamic> noti) {
    String? selected; // 'success' | 'failed'
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.assignment_outlined,
                      color: Colors.orange[700], size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ผลการผสมเทียม',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text('กรุณาแจ้งผลให้สัตวบาลทราบ',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 11,
                              color: Colors.orange[700],
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
              Text('วัวของคุณติดสัดอีกหรือไม่?',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _resultOption(
                      label: '✅ ผสมสำเร็จ',
                      subtitle: 'วัวไม่ติดสัดอีกแล้ว',
                      value: 'success',
                      selected: selected,
                      color: Colors.green,
                      onTap: () => setD(() => selected = 'success'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _resultOption(
                      label: '❌ ไม่สำเร็จ',
                      subtitle: 'วัวยังติดสัดอยู่',
                      value: 'failed',
                      selected: selected,
                      color: Colors.red,
                      onTap: () => setD(() => selected = 'failed'),
                    ),
                  ),
                ],
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
                    child: const Text('ภายหลัง',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selected == null || saving
                        ? null
                        : () async {
                            setD(() => saving = true);
                            await _submitResult(
                              bookingId: noti['ref_booking_id'],
                              result: selected!,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('ยืนยัน',
                            style: GoogleFonts.notoSansThai(
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

  Future<void> _submitResult({
    required int bookingId,
    required String result,
  }) async {
    try {
      await http.put(
        Uri.parse('$apiEndpoint/queuebook/bookings/result/$bookingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'result': result}), // 'success' | 'failed'
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            result == 'success'
                ? 'บันทึกผล: ผสมสำเร็จ ✓'
                : 'บันทึกผล: ไม่สำเร็จ',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor:
              result == 'success' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ));
      }
    } catch (_) {}
  }

  Widget _resultOption({
    required String label,
    required String subtitle,
    required String value,
    required String? selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.grey[600])),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: isSelected
                        ? color.withOpacity(0.8)
                        : Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}