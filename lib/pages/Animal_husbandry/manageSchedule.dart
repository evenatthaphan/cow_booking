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
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00"
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final vet = context.read<DataVetExpert>().datauser;

    if (vet == null) return;

    final uri = Uri.parse('$apiEndpoint/vet/get/schedule/${vet.id}');
    print("Vet datauser: $vet");

    try {
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);

        final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
        for (var item in data) {
          final date = DateTime.parse(item['available_date']);
          final dayKey = DateTime(date.year, date.month, date.day);

          grouped.putIfAbsent(dayKey, () => []);
          grouped[dayKey]!.add({
            "id": item['id'],
            "time": item['available_time'],
            "is_booked": item['is_booked'], // 1=Booked, 0=Free
            "created_at": item['created_at'],
          });
        }

        setState(() {
          _scheduleData = grouped;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch schedule: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching schedule: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _scheduleData[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _showSelectTimeDialog(DateTime day) async {
    final events = _getEventsForDay(day);
    final existingTimes = events.map((e) => e["time"]).toSet();

    final List<String> selectableTimes =
        allSlots.where((t) => !existingTimes.contains(t)).toList();
    final List<String> selectedTimes = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("เพิ่มเวลาว่าง ${day.day}/${day.month}/${day.year}"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: selectableTimes.map((time) {
                    return CheckboxListTile(
                      title: Text(time),
                      value: selectedTimes.contains(time),
                      onChanged: (val) {
                        setState(() {
                          // <-- ใช้ setState ของ StatefulBuilder
                          if (val == true) {
                            selectedTimes.add(time);
                          } else {
                            selectedTimes.remove(time);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ยกเลิก"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedTimes.isNotEmpty) {
                      await _addAvailableTimes(day, selectedTimes);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("บันทึก"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addAvailableTimes(DateTime day, List<String> times) async {
    final vet = context.read<DataVetExpert>().datauser;
    if (vet == null) return;

    final uri = Uri.parse('$apiEndpoint/vet/vet/schedule');
    final body = {
      "vet_expert_id": vet.id,
      "available_date": day.toIso8601String().split("T")[0],
      "available_time": times
    };

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        await _fetchSchedules(); // โหลดตารางใหม่
      } else {
        debugPrint("Failed to add available times: ${res.body}");
      }
    } catch (e) {
      debugPrint("Error adding times: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: const Text(
          'จัดการตารางงาน',
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'ตารางานของคุณ',
                    style: TextStyle(fontSize: 18, color: Colors.green[900]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TableCalendar(
                    locale: 'th_TH',
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    // onDaySelected: (selectedDay, focusedDay) {
                    //   setState(() {
                    //     _selectedDay = selectedDay;
                    //     _focusedDay = focusedDay;
                    //   });
                    // },
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      final events = _getEventsForDay(selectedDay);
                      if (events.isEmpty) {
                        // วันว่างทั้งหมด → เลือกเวลาว่างใหม่
                        await _showSelectTimeDialog(selectedDay);
                      }
                    },

                    onFormatChanged: (format) =>
                        setState(() => _calendarFormat = format),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final events = _getEventsForDay(day);

                        if (events.isNotEmpty) {
                          final allBooked =
                              events.every((e) => e["is_booked"] == 1);
                          final allFree =
                              events.every((e) => e["is_booked"] == 0);

                          Color bgColor;
                          if (allBooked) {
                            bgColor = Colors.red[400]!;
                          } else if (allFree) {
                            bgColor = Colors.green[400]!;
                          } else {
                            bgColor = Colors.blue[400]!; // ผสมกัน
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        return null; // ไม่มีเหตุการณ์
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedDay != null)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children:
                                _getEventsForDay(_selectedDay!).map((event) {
                              return ListTile(
                                leading: Icon(
                                  event["is_booked"] == 1
                                      ? Icons.close
                                      : Icons.check_circle,
                                  color: event["is_booked"] == 1
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                title: Text("เวลา ${event["time"]}"),
                                subtitle: Text(
                                    "ID: ${event["id"]}, สร้าง: ${event["created_at"]}"),
                              );
                            }).toList(),
                          ),
                        ),
                        // แสดงปุ่มเฉพาะวันที่มี slot (มีสี)
                        if (_getEventsForDay(_selectedDay!).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text("เพิ่มเวลาว่าง"),
                              onPressed: () async {
                                await _showSelectTimeDialog(_selectedDay!);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
