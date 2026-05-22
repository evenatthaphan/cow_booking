import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/GetVet_response.dart';
import 'package:cow_booking/model/response/bullstocks_response.dart';
import 'package:cow_booking/pages/farmers/booking_page.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:http/http.dart' as http;

class Seedocprofilepage extends StatefulWidget {
  final int vetId;
  const Seedocprofilepage({super.key, required this.vetId});

  @override
  State<Seedocprofilepage> createState() => _SeedocprofilepageState();
}

class _SeedocprofilepageState extends State<Seedocprofilepage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<Map<String, dynamic>>> _scheduleData = {};
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // ── สีหลัก ──
  static const _darkGreen = Color(0xFF1B5E20);
  static const _green = Color(0xFF2E7D32);
  static const _midGreen = Color(0xFF43A047);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _pageBg = Color(0xFFF1F8F1);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _border = Color(0xFFD8EDD8);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _textSecondary = Color(0xFF5A7A5A);
  static const _labelColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    fetchVetProfile();
    _fetchSchedules();
  }

  Future<void> fetchVetProfile() async {
    final dataVet = Provider.of<DataVetExpert>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/vet/getVetExperts/${widget.vetId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vet = VetExpert(
          id: data['vetexperts_id'] ?? 0,
          vetExpertName: data['vetexperts_name'] ?? '',
          vetExpertPassword: data['vetexperts_hashpassword'] ?? '',
          password: data['vetexperts_password'] ?? '',
          phonenumber: data['vetexperts_phonenumber'] ?? '',
          vetExpertEmail: data['vetexperts_email'] ?? '',
          profileImage: data['vetexperts_profile_image'] ?? '',
          province: data['vetexperts_province'] ?? '',
          district: data['vetexperts_district'] ?? '',
          locality: data['vetexperts_locality'] ?? '',
          vetExpertAddress: data['vetexperts_address'] ?? '',
          vetExpertPl: data['vetexperts_license'] ?? '',
          totalSemenStock: data['total_semen_stock'] ?? 0,
        );
        dataVet.setDataUser(vet);
        dataVet.setPeriod(vet.totalSemenStock);
      }
    } catch (e) {
      debugPrint('Error fetching vet profile: $e');
    }
  }

  Future<List<BullStock>> fetchVetBulls(int vetId) async {
    try {
      final response =
          await http.get(Uri.parse('$apiEndpoint/bull/getby_vetid/$vetId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<BullStock> bulls = [];
        data.forEach((breed, bullList) {
          for (var b in bullList) {
            try {
              bulls.add(BullStock.fromJson(b));
            } catch (_) {}
          }
        });
        return bulls;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchSchedules() async {
    try {
      final res = await http
          .get(Uri.parse('$apiEndpoint/vet/get/schedule/${widget.vetId}'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
        for (var item in data) {
          final date = DateTime.parse(item['schedules_available_date']);
          final dayKey = DateTime(date.year, date.month, date.day);
          grouped.putIfAbsent(dayKey, () => []);
          grouped[dayKey]!.add({
            "id": item['schedules_id'],
            "time": item['schedules_available_time'],
            "is_booked": item['schedules_is_booked'],
            "created_at": item['schedules_created_at'],
          });
        }
        setState(() {
          _scheduleData = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _scheduleData[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // ── Profile header ──
  Widget _buildProfileHeader(VetExpert vet) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkGreen, _midGreen],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundImage: vet.profileImage.isNotEmpty
                  ? NetworkImage(vet.profileImage)
                  : const AssetImage('assets/images/profile.jpg')
                      as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),

          // ชื่อ
          Text(
            vet.vetExpertName.isNotEmpty ? vet.vetExpertName : 'กำลังโหลด...',
            style: GoogleFonts.notoSansThai(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // ที่อยู่
          if (vet.province.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  [vet.locality, vet.district, vet.province]
                      .where((s) => s.isNotEmpty)
                      .join(', '),
                  style: GoogleFonts.notoSansThai(
                      fontSize: 13, color: Colors.white70),
                ),
              ],
            ),

          const SizedBox(height: 14),

          // stats row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('🧪', '${vet.totalSemenStock}', 'โดสในสต็อก'),
                Container(width: 1, height: 36, color: Colors.white24),
                _statItem('📍', vet.province.isNotEmpty ? vet.province : '-',
                    'จังหวัด'),
                Container(width: 1, height: 36, color: Colors.white24),
                _statItem('📞', vet.phonenumber.isNotEmpty ? vet.phonenumber : '-',
                    'เบอร์โทร'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.notoSansThai(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.notoSansThai(
                fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  // ── Tab: สต็อก ──
  Widget _stockTab() {
    return FutureBuilder<List<BullStock>>(
      future: fetchVetBulls(widget.vetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _green));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.science_outlined, size: 48, color: _border),
                const SizedBox(height: 10),
                Text('ไม่มีสต็อกน้ำเชื้อ',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 14, color: _labelColor)),
              ],
            ),
          );
        }

        final bulls = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: bulls.length,
          itemBuilder: (_, i) {
            final bull = bulls[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child:
                          const Icon(Icons.science_outlined, color: _green, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bull.bullname,
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.store_outlined,
                                  size: 12, color: _midGreen),
                              const SizedBox(width: 4),
                              Text(
                                '${bull.bullbreed}  ·  ${bull.farmName}',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 12, color: _textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${bull.semenStock}',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _green),
                          ),
                          Text('โดส',
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 10, color: _textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Tab: ตารางงาน ──
  Widget _workSchedule() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }

    final selectedEvents =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        // legend
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(
            spacing: 12,
            children: [
              _legendItem(Colors.green[400]!, 'ว่าง'),
              _legendItem(Colors.red[400]!, 'เต็มทุกช่วง'),
              _legendItem(Colors.blue[400]!, 'ว่างบางช่วง'),
            ],
          ),
        ),

        // calendar
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: _green.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: TableCalendar(
            locale: 'th_TH',
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (f) => setState(() => _calendarFormat = f),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: _midGreen.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(8),
              ),
              formatButtonTextStyle:
                  GoogleFonts.notoSansThai(fontSize: 12, color: _green),
              titleTextStyle: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: _green),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: _green),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final eventList = _getEventsForDay(day);
                if (eventList.isEmpty) return const SizedBox.shrink();
                final allBooked =
                    eventList.every((e) => e["is_booked"] == 1);
                final allFree =
                    eventList.every((e) => e["is_booked"] == 0);
                Color bg = allBooked
                    ? Colors.red[400]!
                    : allFree
                        ? Colors.green[400]!
                        : Colors.blue[400]!;
                return Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text('${day.day}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // slot list
        if (_selectedDay != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 10),
                Text(
                  'ช่วงเวลาที่ว่าง',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary),
                ),
                const SizedBox(width: 8),
                Text('(${selectedEvents.length} ช่วง)',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 12, color: _labelColor)),
              ],
            ),
          ),
          if (selectedEvents.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_outlined,
                      size: 18, color: _labelColor),
                  const SizedBox(width: 8),
                  Text('ไม่มีตารางงานในวันนี้',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 13, color: _labelColor)),
                ],
              ),
            )
          else
            ...selectedEvents.map((event) {
              final isBooked = event["is_booked"] == 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBooked
                        ? Colors.red.withOpacity(0.2)
                        : _border,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: _green.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.red.withOpacity(0.1)
                              : _lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isBooked
                              ? Icons.cancel_outlined
                              : Icons.check_circle_outline_rounded,
                          color: isBooked ? Colors.red[400] : _green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เวลา ${event["time"]}',
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary),
                            ),
                            Text(
                              isBooked ? 'ถูกจองแล้ว' : 'ว่าง',
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 12,
                                  color: isBooked
                                      ? Colors.red[400]
                                      : _midGreen),
                            ),
                          ],
                        ),
                      ),
                      if (!isBooked)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Bookingpage(
                                vetId: widget.vetId,
                                scheduleId: event["id"],
                                selectedDay: _selectedDay!,
                                selectedTime: event["time"],
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('จอง',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ] else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: _labelColor),
                const SizedBox(width: 8),
                Text('เลือกวันในปฏิทินเพื่อดูตารางงาน',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 13, color: _labelColor)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.notoSansThai(
                fontSize: 11, color: _labelColor)),
      ],
    );
  }

  Widget _mapAddress() {
    return Consumer<DataVetExpert>(
      builder: (_, dataVet, __) {
        final vet = dataVet.datauser;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.map_outlined,
                      color: _green, size: 32),
                ),
                const SizedBox(height: 16),
                Text(vet.vetExpertAddress.isNotEmpty
                    ? vet.vetExpertAddress
                    : 'ไม่ระบุที่อยู่',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 14, color: _textPrimary)),
                const SizedBox(height: 6),
                Text(
                  [vet.locality, vet.district, vet.province]
                      .where((s) => s.isNotEmpty)
                      .join(', '),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                      fontSize: 13, color: _labelColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // ── Profile header ──
            Consumer<DataVetExpert>(
              builder: (_, dataVet, __) => _buildProfileHeader(dataVet.datauser),
            ),

            // ── TabBar ──
            Container(
              color: _cardBg,
              child: TabBar(
                labelColor: _green,
                unselectedLabelColor: _labelColor,
                indicatorColor: _green,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.notoSansThai(
                    fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle:
                    GoogleFonts.notoSansThai(fontSize: 14),
                tabs: const [
                  Tab(icon: Icon(Icons.science_outlined, size: 18), text: 'สต็อก'),
                  Tab(icon: Icon(Icons.calendar_month_outlined, size: 18), text: 'ตารางงาน'),
                  Tab(icon: Icon(Icons.location_on_outlined, size: 18), text: 'ที่อยู่'),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),

            Expanded(
              child: TabBarView(
                children: [
                  _stockTab(),
                  _workSchedule(),
                  _mapAddress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _darkGreen,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_darkGreen, _midGreen],
          ),
        ),
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
              Text('Cow Booking',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1)),
              Text('โปรไฟล์สัตวบาล',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 11, color: Colors.white70, height: 1.1)),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child:
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }
}