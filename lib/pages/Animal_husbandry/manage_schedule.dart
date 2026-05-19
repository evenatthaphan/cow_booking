import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ManageschedulePage extends StatefulWidget {
  const ManageschedulePage({super.key});

  @override
  State<ManageschedulePage> createState() => _ManageschedulePageState();
}

class _ManageschedulePageState extends State<ManageschedulePage> {
  late Map<DateTime, List<Map<String, dynamic>>> _scheduleData = {};
  bool _isLoading = true;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final allSlots = [
    "08:00", "09:00", "10:00", "11:00", "12:00",
    "13:00", "14:00", "15:00", "16:00", "17:00"
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final vet = context.read<DataVetExpert>().datauser;
    final uri = Uri.parse('$apiEndpoint/vet/get/schedule/${vet.id}');

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final Map<DateTime, List<Map<String, dynamic>>> grouped = {};

        for (var item in data) {
          try {
            final rawDate = item['schedules_available_date'];
            if (rawDate == null) continue;
            final date = DateTime.tryParse(rawDate.toString());
            if (date == null) continue;
            final dayKey = DateTime(date.year, date.month, date.day);
            grouped.putIfAbsent(dayKey, () => []);
            grouped[dayKey]!.add({
              "id":         item['schedules_id'],
              "time":       item['schedules_available_time']?.toString() ?? '',
              "is_booked":  item['schedules_is_booked'] ?? 0,
              "created_at": item['schedules_created_at']?.toString() ?? '-',
            });
          } catch (_) { continue; }
        }

        setState(() { _scheduleData = grouped; _isLoading = false; });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) =>
      _scheduleData[DateTime(day.year, day.month, day.day)] ?? [];

  Future<void> _showSelectTimeDialog(DateTime day) async {
    final events    = _getEventsForDay(day);
    final existing  = events.map((e) => e["time"]).toSet();
    final selectable = allSlots.where((t) => !existing.contains(t)).toList();
    final selected  = <String>[];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add_alarm, color: Colors.green[700], size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('เพิ่มเวลาว่าง',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${day.day}/${day.month}/${day.year}',
                      style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          content: selectable.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('ไม่มีช่วงเวลาที่สามารถเพิ่มได้แล้ว',
                      style: TextStyle(color: Colors.grey)),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3,
                    children: selectable.map((time) {
                      final isSelected = selected.contains(time);
                      return GestureDetector(
                        onTap: () => setS(() {
                          isSelected ? selected.remove(time) : selected.add(time);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey[300]!,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                    onPressed: selected.isEmpty
                        ? null
                        : () async {
                            await _addAvailableTimes(day, selected);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      selected.isEmpty ? 'บันทึก' : 'บันทึก (${selected.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAvailableTimes(DateTime day, List<String> times) async {
    final vet = context.read<DataVetExpert>().datauser;
    final uri = Uri.parse('$apiEndpoint/vet/vet/schedule');
    final body = {
      "vet_expert_id": vet.id,
      "available_date": day.toIso8601String().split("T")[0],
      "available_time": times,
    };

    try {
      final res = await http.post(uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));
      if (res.statusCode == 201) await _fetchSchedules();
    } catch (e) {
      debugPrint("Error adding times: $e");
    }
  }

  // ── สีตามสถานะวัน ─────────────────────────────────────────────────────────
  Color _dayColor(List<Map<String, dynamic>> events) {
    if (events.isEmpty) return Colors.transparent;
    final allBooked = events.every((e) => e["is_booked"] == 1);
    final allFree   = events.every((e) => e["is_booked"] == 0);
    if (allBooked) return Colors.red[400]!;
    if (allFree)   return Colors.green[500]!;
    return Colors.blue[400]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[800]),
        title: Text('จัดการตารางงาน',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                // Legend 
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(Colors.green[500]!, 'ว่างทั้งหมด'),
                      const SizedBox(width: 16),
                      _legendDot(Colors.blue[400]!, 'ว่างบางส่วน'),
                      const SizedBox(width: 16),
                      _legendDot(Colors.red[400]!, 'เต็มทั้งหมด'),
                    ],
                  ),
                ),

                // Calendar 
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    locale: 'th_TH',
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay  = focusedDay;
                      });
                      if (_getEventsForDay(selectedDay).isEmpty) {
                        await _showSelectTimeDialog(selectedDay);
                      }
                    },
                    onFormatChanged: (f) => setState(() => _calendarFormat = f),
                    onPageChanged: (fd) => _focusedDay = fd,
                    headerStyle: HeaderStyle(
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      formatButtonTextStyle: TextStyle(color: Colors.green[800], fontSize: 12),
                      titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.green[700]),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.green[700]),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.green[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      weekendTextStyle: TextStyle(color: Colors.red[400]),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (ctx, day, focusedDay) {
                        final events = _getEventsForDay(day);
                        if (events.isEmpty) return null;
                        final color = _dayColor(events);
                        final isSelected = isSameDay(_selectedDay, day);
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // รายการ slot 
                if (_selectedDay != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.green[700]),
                              const SizedBox(width: 6),
                              Text(
                                'วันที่ ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _getEventsForDay(_selectedDay!).isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
                                      const SizedBox(height: 8),
                                      Text('ยังไม่มีเวลาว่างในวันนี้',
                                          style: TextStyle(color: Colors.grey[500])),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _showSelectTimeDialog(_selectedDay!),
                                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                        label: const Text('เพิ่มเวลาว่าง',
                                            style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  children: [
                                    ..._getEventsForDay(_selectedDay!).map((event) {
                                      final isBooked = event["is_booked"] == 1;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isBooked
                                                  ? Colors.red[50]
                                                  : Colors.green[50],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              isBooked
                                                  ? Icons.event_busy
                                                  : Icons.event_available,
                                              color: isBooked ? Colors.red : Colors.green,
                                              size: 22,
                                            ),
                                          ),
                                          title: Text(
                                            'เวลา ${event["time"]} น.',
                                            style: const TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isBooked
                                                  ? Colors.red[50]
                                                  : Colors.green[50],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isBooked ? 'ถูกจองแล้ว' : 'ว่าง',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isBooked
                                                    ? Colors.red[700]
                                                    : Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    // ปุ่มเพิ่มเวลา 
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showSelectTimeDialog(_selectedDay!),
                                        icon: Icon(Icons.add, color: Colors.green[700], size: 18),
                                        label: Text('เพิ่มเวลาว่าง',
                                            style: TextStyle(color: Colors.green[700])),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.green[400]!),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );
}