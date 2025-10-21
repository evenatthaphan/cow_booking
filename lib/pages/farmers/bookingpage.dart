import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/bullstocks_response.dart';
import 'package:cow_booking/pages/farmers/acceptbooking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:http/http.dart' as http;

class Bookingpage extends StatefulWidget {
  final int vetId; // vet_expert_id
  final int scheduleId; // schedule_id
  final DateTime selectedDay; // วันที่เลือก
  final String selectedTime; // เวลาที่เลือก

  const Bookingpage({
    super.key,
    required this.vetId,
    required this.scheduleId,
    required this.selectedDay,
    required this.selectedTime,
  });

  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  String? vetName;
  List<BullStock> bullList = [];
  BullStock? selectedBull;
  bool isLoading = true;

  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataVet = Provider.of<DataVetExpert>(context, listen: false);

    if (dataVet.datauser.id == widget.vetId) {
      vetName = dataVet.datauser.vetExpertName;
    } else {
      vetName = 'สัตวบาลหมายเลข ${widget.vetId}';
    }

    _loadVetBulls();
  }

  Future<void> _loadVetBulls() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/bull/getby_vetid/${widget.vetId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<BullStock> bulls = [];

        data.forEach((breed, bullList) {
          for (var b in bullList) {
            bulls.add(BullStock.fromJson(b));
          }
        });

        setState(() {
          bullList = bulls;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch bulls: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bulls: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showConfirmDialog() async {
    if (selectedBull == null || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกวัวและระบุจำนวนโดส")),
      );
      return;
    }

    final dataFarmer = Provider.of<DataFarmers>(context, listen: false);
    final int farmerId = dataFarmer.datauser.id ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการจอง"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ชื่อผู้จอง: ${dataFarmer.datauser.farmName}"),
            Text("ชื่อสัตวบาล: $vetName"),
            Text(
                "วันที่/เวลา: ${widget.selectedDay.toLocal().toString().split(' ')[0]} ${widget.selectedTime}"),
            Text("ชื่อวัว: ${selectedBull!.bullname}"),
            Text("พันธุ์วัว: ${selectedBull!.bullbreed}"),
            Text("จำนวนโดส: ${_doseController.text}"),
            if (_detailController.text.isNotEmpty)
              Text("รายละเอียดแม่พันธุ์: ${_detailController.text}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.red),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[900]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _submitBooking(farmerId);
    }
  }

  Future<void> _submitBooking(int farmerId) async {
    final body = {
      "farmer_id": farmerId,
      "vet_expert_id": widget.vetId,
      "bull_id": selectedBull!.vetBullId,
      "dose": int.parse(_doseController.text),
      "schedule_id": widget.scheduleId,
      "detailBull": _detailController.text,
    };

    print("Booking payload: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/queuebook/queue/book'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("จองคิวสำเร็จ")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Acceptbookingpage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Booking error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: const Text(
          'จองคิวผสมเทียม',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'คุณต้องการจองคิวกับ $vetName',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // 
                  DropdownButtonFormField<BullStock>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "เลือกวัวสำหรับผสมเทียม",
                    ),
                    value: selectedBull,
                    items: bullList.map((bull) {
                      return DropdownMenuItem<BullStock>(
                        value: bull,
                        child: Text(
                          '${bull.bullbreed} (${bull.bullname})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (BullStock? newValue) {
                      setState(() {
                        selectedBull = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // 
                  TextField(
                    controller: _doseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'จำนวนโดส',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 
                  TextField(
                    controller: _detailController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'รายละเอียดแม่พันธุ์ (เช่น อายุ, สุขภาพ)',
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen[700],
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                    ),
                    onPressed: _showConfirmDialog,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'ยืนยันการจอง',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
