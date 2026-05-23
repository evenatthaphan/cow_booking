import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/doc_profile.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DetailqueuePage extends StatefulWidget {
  final BookingResponse booking;

  const DetailqueuePage({
    super.key,
    required this.booking,
  });

  @override
  State<DetailqueuePage> createState() => _DetailqueuePageState();
}

class _DetailqueuePageState extends State<DetailqueuePage> {
  bool _isLoading = false;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.bookingsStatus;
  }

  // API อัพเดตสถานะ 
  Future<void> _updateBookingStatus(String status, {String? vetNotes}) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('$apiEndpoint/queuebook/bookings/update/${widget.booking.queueBookingsId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          if (vetNotes != null && vetNotes.isNotEmpty) 'vet_notes': vetNotes,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _currentStatus = status);
        _showResultSnackbar(
          status == 'accepted' ? 'ยืนยันการจองเรียบร้อยแล้ว ✓' : 'ปฏิเสธการจองเรียบร้อยแล้ว',
          status == 'accepted' ? Colors.green : Colors.red,
        );
      } else {
        final body = jsonDecode(response.body);
        _showResultSnackbar('เกิดข้อผิดพลาด: ${body['error'] ?? 'ไม่ทราบสาเหตุ'}', Colors.red);
      }
    } catch (e) {
      if (mounted) _showResultSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // Dialog ยืนยันการจอง 
  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('ยืนยันการจอง',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณต้องการยืนยันรับคิวนี้ใช่หรือไม่?',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 14),
            _dialogInfoChip(Icons.person_outline, widget.booking.farmersName),
            const SizedBox(height: 6),
            _dialogInfoChip(
              Icons.calendar_today,
              '${DateFormat('dd/MM/yyyy').format(widget.booking.scheduleDate)}  •  ${widget.booking.scheduleTime}',
            ),
            const SizedBox(height: 6),
            _dialogInfoChip(Icons.science_outlined, '${widget.booking.bookingsDose} โดส'),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateBookingStatus('accepted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยืนยัน',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog ปฏิเสธ 
  void _showRejectDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('ปฏิเสธการจอง',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณต้องการปฏิเสธคิวนี้ใช่หรือไม่?',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'ระบุเหตุผลการปฏิเสธ (ไม่บังคับ)',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final notes = noteController.text.trim();
                    Navigator.pop(ctx);
                    _updateBookingStatus('rejected', vetNotes: notes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ปฏิเสธ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.green[900]),
          onPressed: () => Navigator.pop(context),
        ),
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
                    'รายละเอียดการจอง',
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
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VetProfilePage()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<DataVetExpert>(
                builder: (context, dataVet, _) {
                  final imageUrl = dataVet.datauser.profileImage;
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: (imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : const NetworkImage(
                            'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // รายละเอียดการจอง
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapSection(booking),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("ข้อมูลเกษตรกร"),
                        _infoCard([_infoRow(Icons.person, "ชื่อเกษตรกร", booking.farmersName)]),

                        const SizedBox(height: 14),
                        _sectionLabel("ข้อมูลนัดหมาย"),
                        _infoCard([
                          _infoRow(Icons.calendar_today, "วันที่",
                              DateFormat('dd MMMM yyyy', 'th').format(booking.scheduleDate)),
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          _infoRow(Icons.access_time, "เวลา", booking.scheduleTime),
                        ]),

                        const SizedBox(height: 14),
                        _sectionLabel("ข้อมูลพ่อพันธุ์"),
                        _infoCard([
                          _infoRow(Icons.pets, "ชื่อพ่อพันธุ์", booking.bullsName),
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          _infoRow(Icons.category, "สายพันธุ์", booking.bullsBreed),
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          _infoRow(Icons.science, "จำนวนโดส", "${booking.bookingsDose} โดส"),
                        ]),

                        const SizedBox(height: 14),
                        _sectionLabel("รายละเอียดเพิ่มเติม"),
                        _infoCard([
                          _infoRow(Icons.notes, "หมายเหตุ",
                              booking.bookingsDetailBull.isNotEmpty
                                  ? booking.bookingsDetailBull
                                  : "-"),
                        ]),

                        const SizedBox(height: 14),
                        _sectionLabel("สถานะ"),
                        _infoCard([_statusRow(_currentStatus)]),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action bar (แสดงเฉพาะตอน pending) 
          if (_currentStatus == 'pending')
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                children: [
                  // ปุ่มปฏิเสธ
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _showRejectDialog,
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                      label: const Text('ปฏิเสธ',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ปุ่มยืนยัน
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showAcceptDialog,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check, size: 18, color: Colors.white),
                      label: Text(
                        _isLoading ? 'กำลังบันทึก...' : 'ยืนยันรับคิว',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // แผนที่ placeholder 
  Widget _buildMapSection(BookingResponse booking) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          color: const Color(0xFFD6EAD4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.green[700]),
              const SizedBox(height: 8),
              Text("แผนที่บ้านเกษตรกร",
                  style: TextStyle(
                      fontSize: 15, color: Colors.green[800], fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("กำลังโหลดแผนที่...",
                  style: TextStyle(fontSize: 12, color: Colors.green[600])),
            ],
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(booking.farmersName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        width: double.infinity,
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
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A))),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _statusRow(String status) {
    final Color bgColor;
    final Color textColor;
    final String label;
    final IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
        bgColor = const Color(0xFFE8F5E9);
        textColor = Colors.green[800]!;
        label = "ตอบรับแล้ว";
        icon = Icons.check_circle;
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red[800]!;
        label = "ปฏิเสธ";
        icon = Icons.cancel;
        break;
      default:
        bgColor = const Color(0xFFFFF8E1);
        textColor = Colors.orange[800]!;
        label = "รอการตอบรับ";
        icon = Icons.hourglass_empty;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.green[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("สถานะการจอง",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration:
                    BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: textColor),
                    const SizedBox(width: 4),
                    Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
