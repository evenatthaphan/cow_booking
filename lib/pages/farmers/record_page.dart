import 'package:cow_booking/pages/farmers/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cow_booking/config/internal_config.dart';

class InseminationRecordPage extends StatefulWidget {
  final int bookingId;
  final String vetName;   
  final String detail;    
  final String createdAt;
  const InseminationRecordPage({super.key, 
  required this.bookingId,
  required this.vetName,   
  required this.detail,    
  required this.createdAt});

  @override
  State<InseminationRecordPage> createState() => _InseminationRecordPageState();
}

class _InseminationRecordPageState extends State<InseminationRecordPage> {
  bool? _isSuccess;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  // Future<void> _submitRecord() async {
  //   if (_isSuccess == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('กรุณาเลือกผลการผสม')),
  //     );
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   setState(() => _isLoading = false);

  //   // ไปหน้า Dashboard หลัง submit
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => const InseminationDashboardPage()),
  //   );
  // }

  Future<void> _submitRecord() async {
    if (_isSuccess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกผลการผสม')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/stats/record'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': widget.bookingId,
          'is_success': _isSuccess,
          'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกผลการผสมสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InseminationDashboardPage()),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['error'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถเชื่อมต่อได้'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('บันทึกผลการผสมเทียม'  , style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:  Colors.lightGreen[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking data
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ข้อมูลการจอง',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    _infoRow(Icons.confirmation_number, 'หมายเลขการจอง', '#${widget.bookingId}'),
                    // _infoRow(Icons.pets, 'น้ำเชื้อวัว', 'บราห์มัน #3'),
                    // _infoRow(Icons.person, 'สัตวแพทย์', 'นายสมชาย ใจดี'),
                    // _infoRow(Icons.calendar_today, 'วันที่ผสม', '18 ต.ค. 2568'),
                    _infoRow(Icons.description,   'รายละเอียด',  widget.detail),
                    _infoRow(Icons.person,        'สัตวแพทย์',   widget.vetName),
                    _infoRow(Icons.calendar_today,'วันที่จอง',   widget.createdAt),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text('ผลการผสมเทียม *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _resultCard(
                    label: 'สำเร็จ',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    selected: _isSuccess == true,
                    onTap: () => setState(() => _isSuccess = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _resultCard(
                    label: 'ไม่สำเร็จ',
                    icon: Icons.cancel,
                    color: Colors.red,
                    selected: _isSuccess == false,
                    onTap: () => setState(() => _isSuccess = false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text('หมายเหตุ (ถ้ามี)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'เช่น ผสมครั้งแรก, วัวมีอาการผิดปกติ...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ยืนยันผลการผสม',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _resultCard({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white,
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 36),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  color: selected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                )),
          ],
        ),
      ),
    );
  }
}