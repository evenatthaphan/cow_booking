import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/booking_response.dart';
import 'package:cow_booking/pages/Animal_husbandry/doc_profile.dart';
import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:cow_booking/pages/farmers/farmer_profile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DetailqueueFarmerPage extends StatefulWidget {
  final BookingResponse booking;

  const DetailqueueFarmerPage({
    super.key,
    required this.booking,
  });

  @override
  State<DetailqueueFarmerPage> createState() => _DetailqueueFarmerPageState();
}

class _DetailqueueFarmerPageState extends State<DetailqueueFarmerPage> {
  bool _isLoading = false;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.bookingsStatus;
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "รายละเอียดคิว",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Farmerprofilepage()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<DataFarmers>(
                builder: (context, dataFarmers, _) {
                  final imageUrl = dataFarmers.datauser.farmersProfileImage;
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
                        _sectionLabel("ข้อมูลสัตวบาล"),
                        _infoCard([_infoRow(Icons.person, "ชื่อสัตวบาล", booking.vetexpertsName)]),

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
              
            ),
        ],
      ),
      bottomNavigationBar: FarmerNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (value) {},
        screenSize: screenSize,
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
