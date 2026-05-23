import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/bullstocks_response.dart';
import 'package:cow_booking/pages/farmers/farmmer_booking.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:http/http.dart' as http;

class Bookingpage extends StatefulWidget {
  final int vetId;
  final int scheduleId;
  final DateTime selectedDay;
  final String selectedTime;

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
  int? selectedBullId;
  bool isLoading = true;

  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _doseController   = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataVet = Provider.of<DataVetExpert>(context, listen: false);
    vetName = dataVet.datauser.id == widget.vetId
        ? dataVet.datauser.vetExpertName
        : 'สัตวบาลหมายเลข ${widget.vetId}';
    _loadVetBulls();
  }

  static const _green = Color(0xFF2E7D32);

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
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
              Text(
                'Cow Booking',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'จองคิวผสมเทียมกับ ${vetName ?? 'สัตวบาล'}',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  Future<void> _loadVetBulls() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/bull/getby_vetid/${widget.vetId}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<BullStock> bulls = [];
        data.forEach((breed, list) {
          for (var b in list) bulls.add(BullStock.fromJson(b));
        });
        setState(() { bullList = bulls; isLoading = false; });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showConfirmDialog() async {
    final bull = bullList.where((b) => b.vetBullId == selectedBullId).isNotEmpty
        ? bullList.firstWhere((b) => b.vetBullId == selectedBullId)
        : null;

    if (bull == null || _doseController.text.isEmpty) {
      _showSnackbar('กรุณาเลือกวัวและระบุจำนวนโดส', Colors.red);
      return;
    }

    final dataFarmer = Provider.of<DataFarmers>(context, listen: false);
    final int farmerId = dataFarmer.datauser.farmersId ?? 0;
    final dateStr = DateFormat('dd MMMM yyyy', 'th').format(widget.selectedDay);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.event_available, color: Colors.green[700], size: 22),
              ),
              const SizedBox(width: 10),
              const Text('ยืนยันการจอง',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _confirmRow(Icons.person_outline,       'ผู้จอง',       dataFarmer.datauser.farmersName),
            _confirmRow(Icons.medical_services_outlined, 'สัตวบาล', vetName ?? '-'),
            _confirmRow(Icons.calendar_today,       'วันที่',       dateStr),
            _confirmRow(Icons.access_time,          'เวลา',        widget.selectedTime),
            _confirmRow(Icons.pets,                 'พ่อพันธุ์',   '${bull.bullname} (${bull.bullbreed})'),
            _confirmRow(Icons.science_outlined,     'จำนวนโดส',    '${_doseController.text} โดส'),
            if (_detailController.text.isNotEmpty)
              _confirmRow(Icons.notes, 'รายละเอียด', _detailController.text),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
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

    if (confirm == true) _submitBooking(farmerId);
  }

  Future<void> _submitBooking(int farmerId) async {
    final body = {
      "farmer_id":    farmerId,
      "vet_expert_id": widget.vetId,
      "bull_id":      selectedBullId,
      "dose":         int.parse(_doseController.text),
      "schedule_id":  widget.scheduleId,
      "detailBull":   _detailController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/queuebook/queue/book'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar('จองคิวสำเร็จ ✓', Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Farmmerbookingpage()),
        );
      } else {
        _showSnackbar('เกิดข้อผิดพลาด: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้', Colors.red);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header ข้อมูลนัดหมาย ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('นัดหมายกับ',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(vetName ?? '-',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _headerChip(Icons.calendar_today,
                                DateFormat('dd MMM yyyy', 'th').format(widget.selectedDay)),
                            const SizedBox(width: 10),
                            _headerChip(Icons.access_time, widget.selectedTime),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── เลือกพ่อพันธุ์ ────────────────────────────────────
                  _sectionLabel('เลือกพ่อพันธุ์'),
                  _infoCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.pets, size: 20, color: Colors.green[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedBullId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'พ่อพันธุ์สำหรับผสมเทียม',
                                labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              items: bullList.map((bull) => DropdownMenuItem<int>(
                                value: bull.vetBullId,
                                child: Text('${bull.bullname}  (${bull.bullbreed})',
                                    overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (v) => setState(() => selectedBullId = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // ── จำนวนโดส + รายละเอียด ─────────────────────────────
                  _sectionLabel('รายละเอียดการจอง'),
                  _infoCard([
                    _inputField(
                      controller: _doseController,
                      label: 'จำนวนโดส',
                      icon: Icons.science_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(height: 1, indent: 52, color: Color(0xFFEEEEEE)),
                    _inputField(
                      controller: _detailController,
                      label: 'รายละเอียดแม่พันธุ์ (อายุ, สุขภาพ ฯลฯ)',
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // ── ปุ่มยืนยัน ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showConfirmDialog,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 20),
                      label: const Text('ยืนยันการจอง',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _headerChip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      );

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Icon(icon, size: 20, color: Colors.green[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _confirmRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.green[600]),
            const SizedBox(width: 8),
            Text('$label: ',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}