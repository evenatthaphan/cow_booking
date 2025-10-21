import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/GetVet_response.dart';
import 'package:cow_booking/model/response/bullstocks_response.dart';
import 'package:cow_booking/pages/farmers/bookingpage.dart';
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

class Event {
  final String title;
  final String? time;
  final String? location;

  Event(this.title, {this.time, this.location});
}

class _SeedocprofilepageState extends State<Seedocprofilepage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // final Map<DateTime, List<Event>> _events = {
  //   DateTime(2025, 8, 1): [Event('ผสมเทียมวัว')],
  //   DateTime(2025, 7, 31): [
  //     Event('นัดพบหมอ', time: '09:00 น.', location: 'คลินิกสัตว์'),
  //     Event('ประชุมทีม', time: '13:00 น.')
  //   ],
  // };

  late Map<DateTime, List<Map<String, dynamic>>> _scheduleData = {};
  bool _isLoading = true;

  CalendarFormat _calendarFormat = CalendarFormat.month;

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

        final getVet = GetVetExpert.fromJson(data);

        final vet = VetExpert(
          id: getVet.id,
          vetExpertName: getVet.vetExpertName,
          vetExpertPassword: getVet.vetExpertPassword,
          phonenumber: getVet.phonenumber,
          vetExpertEmail: getVet.vetExpertEmail,
          profileImage: getVet.profileImage,
          vetExpertAddress: getVet.vetExpertAddress,
          province: getVet.province,
          district: getVet.district,
          locality: getVet.locality,
          vetExpertPl: getVet.vetExpertPl,
          totalSemenStock: getVet.totalSemenStock,
        );

        // VetExpert
        dataVet.setDataUser(vet);

        // total stock
        dataVet.setPeriod(getVet.totalSemenStock);
      } else {
        print('Failed to fetch vet: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vet profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen[700],
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'โปรไฟล์สัตวบาล',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<DataVetExpert>(
                builder: (context, dataVet, _) {
                  final vet = dataVet.datauser;
                  return Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: vet.profileImage.isNotEmpty
                              ? NetworkImage(vet.profileImage)
                              : const AssetImage('assets/images/pin.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          vet.vetExpertName,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vet.vetExpertAddress,
                          style: GoogleFonts.notoSansThai(fontSize: 16),
                        ),
                        Text(
                          'ตำบล${vet.locality} อำเภอ${vet.district} จังหวัด${vet.province}',
                          style: GoogleFonts.notoSansThai(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'มีน้ำเชื้อในสต๊อก ${vet.totalSemenStock > 0 ? vet.totalSemenStock : 0} โดส',
                          style: GoogleFonts.notoSansThai(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              labelColor: Colors.green[600],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'สต๊อก'),
                Tab(text: 'ตารางงาน'),
                Tab(text: 'ที่อยู่'),
              ],
            ),
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

  Future<List<BullStock>> fetchVetBulls(int vetId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/bull/getby_vetid/$vetId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<BullStock> bulls = [];

        data.forEach((breed, bullList) {
          for (var b in bullList) {
            bulls.add(BullStock.fromJson(b));
          }
        });

        return bulls;
      } else {
        print('Failed to fetch bulls: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching bulls: $e');
      return [];
    }
  }


  Widget _stockTab() {
    return FutureBuilder<List<BullStock>>(
      future: fetchVetBulls(widget.vetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('ไม่มีสต๊อกน้ำเชื้อ'));
        }

        final bulls = snapshot.data!;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bulls.length,
                itemBuilder: (context, index) {
                  final bull = bulls[index];
                  return ListTile(
                    leading: const Icon(Icons.library_add_check),
                    title: Text(bull.bullname),
                    subtitle: Text('${bull.bullbreed} จาก ${bull.farmName}'),
                    trailing: Text(
                      ' ${bull.semenStock} โดส',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 14, 88, 41)),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchSchedules() async {
    final vet = context.read<DataVetExpert>().datauser;

    if (vet == null) return;

    final uri = Uri.parse('$apiEndpoint/vet/get/schedule/${widget.vetId}');
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

  // List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
  //   final key = DateTime.utc(day.year, day.month, day.day);
  //   return _scheduleData[key] ?? [];
  // }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _scheduleData[key] ?? [];
  }

  Widget _workSchedule() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TableCalendar(
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
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final eventList = _getEventsForDay(day);
                    if (eventList.isEmpty) return const SizedBox.shrink();

                    final allBooked =
                        eventList.every((e) => e["is_booked"] == 1);
                    final allFree = eventList.every((e) => e["is_booked"] == 0);

                    Color bgColor;
                    if (allBooked) {
                      bgColor = Colors.red[400]!;
                    } else if (allFree) {
                      bgColor = Colors.green[400]!;
                    } else {
                      bgColor = Colors.blue[400]!;
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
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              if (_selectedDay != null)
                ..._getEventsForDay(_selectedDay!).map((event) {
                  bool isBooked = event["is_booked"] == 1;
                  return ListTile(
                    leading: Icon(
                      isBooked ? Icons.close : Icons.check_circle,
                      color: isBooked ? Colors.red : Colors.green,
                    ),
                    title: Text("เวลา ${event["time"]}"),
                    trailing: isBooked
                        ? null
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Bookingpage(
                                    vetId: widget.vetId,
                                    scheduleId: event["id"],
                                    selectedDay: _selectedDay!,
                                    selectedTime: event["time"],
                                  ),
                                ),
                              );
                            },
                            child: const Text("จอง"),
                          ),
                  );
                }).toList(),
            ],
          );
  }

  Widget _mapAddress() {
    return const Center(child: Text('map'));
  }
}
