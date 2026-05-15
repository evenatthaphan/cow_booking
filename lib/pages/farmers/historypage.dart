import 'package:cow_booking/pages/farmers/recordpage.dart';
import 'package:flutter/material.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cow_booking/config/internal_config.dart';
import 'dart:convert';

class InseminationHistoryPage extends StatefulWidget {
  final int farmerId;

  const InseminationHistoryPage({super.key, 
    required this.farmerId
});

  @override
  State<InseminationHistoryPage> createState() => _InseminationHistoryPageState();
}

class _InseminationHistoryPageState extends State<InseminationHistoryPage> {
  List<Map<String, dynamic>> bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '$apiEndpoint/queuebook/bookings/farmer?farmer_id=${widget.farmerId}',
      );

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // กรองเฉพาะ accepted เท่านั้น
          bookings = data
            .where((b) => b['bookings_status'] == 'accepted')
            .map((b) => {
                  'booking_id': b['queue_bookings_id'],
                  'bull_id':    b['ref_bulls_id'],
                  'vet_name':   b['vetexperts_name'] ?? 'ไม่ระบุ',
                  'detail':     b['bookings_detail_bull'] ?? '-',
                  'vet_notes':  b['bookings_vet_notes'] ?? '-',
                  'created_at': b['created_at'],
                  'is_recorded': b['record_id'] != null,
                  'is_success':  b['record_id'] != null ? b['is_success'] == 1 : null,
                })
            .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'เกิดข้อผิดพลาด: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('ประวัติการผสมเทียม',
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor:  Colors.lightGreen[700],
        foregroundColor: Colors.white,
        actions: [
          // ปุ่ม refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: Colors.grey, size: 48),
            SizedBox(height: 12),
            Text('ยังไม่มีประวัติการผสม',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4CAF50),
      onRefresh: _fetchBookings, // ดึงข้อมูลใหม่เมื่อ pull down
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          final bool isRecorded = b['is_recorded'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header 
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'การจอง #${b['booking_id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _statusBadge(isRecorded, b['is_success'] as bool?),
                    ],
                  ),

                  const Divider(height: 16),

                  _infoRow(Icons.person, 'สัตวแพทย์', b['vet_name']),
                  const SizedBox(height: 4),
                  _infoRow(Icons.description, 'รายละเอียด', b['detail']),
                  const SizedBox(height: 4),
                  _infoRow(Icons.note, 'หมายเหตุหมอ', b['vet_notes']),

                  if (!isRecorded) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (_) => InseminationRecordPage(
                        //         bookingId: b['booking_id'],
                        //       ),
                        //     ),
                        //   ).then((_) => _fetchBookings()); // refresh หลังกลับมา
                        // },
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InseminationRecordPage(
                                bookingId: b['booking_id'],
                                vetName:   b['vet_name'],
                                detail:    b['detail'],
                                createdAt: b['created_at'] ?? '-',
                              ),
                            ),
                          ).then((_) => _fetchBookings());
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('กรอกผลการผสม'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _statusBadge(bool isRecorded, bool? isSuccess) {
    String label;
    Color color;

    if (!isRecorded) {
      label = 'รอกรอกผล';
      color = Colors.orange;
    } else if (isSuccess == true) {
      label = 'กรอกผลแล้ว · สำเร็จ';
      color = Colors.green;
    } else {
      label = 'กรอกผลแล้ว · ไม่สำเร็จ';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label : ',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}