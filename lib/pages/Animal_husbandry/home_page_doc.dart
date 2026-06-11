import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/detail_queue.dart';
import 'package:cow_booking/pages/Animal_husbandry/doc_profile.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Homepagedoc extends StatefulWidget {
  @override
  State<Homepagedoc> createState() => _HomepagedocState();
}

class _HomepagedocState extends State<Homepagedoc> {
  bool _isLoading = true;
  List<BookingResponse> _pending  = [];
  List<BookingResponse> _accepted = [];
  List<BookingResponse> _rejected = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchBookings());
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    final vetId = context.read<DataVetExpert>().datauser.id;
    setState(() => _isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/queuebook/bookings/vet/$vetId'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final all = data.map((e) => BookingResponse.fromJson(e)).toList();
        setState(() {
          _pending  = all.where((b) => b.bookingsStatus == 'pending').toList();
          _accepted = all.where((b) => b.bookingsStatus == 'accepted').toList();
          _rejected = all.where((b) => b.bookingsStatus == 'rejected').toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('🐄', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cow Booking',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.green[900], height: 1.1)),
                  Text('หน้าหลัก',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 11, color: Colors.green[900], height: 1.1)),
                ],
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VetProfilePage())),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Consumer<DataVetExpert>(
                  builder: (_, dataVet, __) {
                    final imageUrl = dataVet.datauser.profileImage;
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const NetworkImage(
                              'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
                    );
                  },
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.green,
            indicatorWeight: 3,
            labelColor: Colors.green,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "คำขอ"),
              Tab(text: "ตอบรับแล้ว"),
              Tab(text: "ปฏิเสธ"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : TabBarView(
                children: [
                  _buildList(_pending,  'pending',  'ยังไม่มีคำขอการจอง'),
                  _buildList(_accepted, 'accepted', 'ยังไม่มีรายการที่ตอบรับแล้ว'),
                  _buildList(_rejected, 'rejected', 'ยังไม่มีรายการที่ปฏิเสธ'),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<BookingResponse> list, String status, String emptyMsg) {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchBookings,   // ← ดึงใหม่ทั้งหมดเมื่อเลื่อนลง
      child: list.isEmpty
          ? ListView(              // ← ต้องเป็น ListView ถึงจะ pull-to-refresh ได้แม้ว่าง
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(emptyMsg,
                          style: TextStyle(fontSize: 15, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _bookingCard(list[i], status),
            ),
    );
  }

  void _goToDetail(BookingResponse booking) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailqueuePage(booking: booking)));
  }

  Widget _bookingCard(BookingResponse booking, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    booking.farmersName.isNotEmpty ? booking.farmersName[0] : '?',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.green[800], fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(booking.farmersName,
                      style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                ),
                _statusBadge(status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                _infoRow(Icons.calendar_today,
                    '${DateFormat('dd MMM yyyy', 'th').format(booking.scheduleDate)}  •  ${booking.scheduleTime}'),
                const SizedBox(height: 8),
                _infoRow(Icons.pets,
                    '${booking.bullsName}  (${booking.bullsBreed})  —  ${booking.bookingsDose} โดส'),
                if (booking.bookingsDetailBull.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoRow(Icons.notes, booking.bookingsDetailBull),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _goToDetail(booking),
                icon: const Icon(Icons.arrow_forward_ios, size: 13, color: Colors.white),
                label: const Text('รายละเอียด', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF444444)))),
        ],
      );

  Widget _statusBadge(String status) {
    final map = {
      'pending':  ('รอตอบรับ',   Colors.orange, const Color(0xFFFFF3E0)),
      'accepted': ('ตอบรับแล้ว', Colors.green,  const Color(0xFFE8F5E9)),
      'rejected': ('ปฏิเสธ',     Colors.red,    const Color(0xFFFFEBEE)),
    };
    final info = map[status] ?? ('ไม่ทราบ', Colors.grey, Colors.grey[100]!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: info.$3, borderRadius: BorderRadius.circular(20)),
      child: Text(info.$1,
          style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.bold, color: info.$2)),
    );
  }
}