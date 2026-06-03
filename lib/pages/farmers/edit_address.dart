import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/Home/map_picker_page.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditaddressPage extends StatefulWidget {
  const EditaddressPage({super.key});

  @override
  State<EditaddressPage> createState() => _EditaddressPageState();
}

class _EditaddressPageState extends State<EditaddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ── สี ──
  static const _green = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);
  static const _border = Color(0xFFDDDDDD);
  static const _labelColor = Color(0xFF757575);

  static const _googleApiKey = 'YOUR_GOOGLE_API_KEY';

  // ── Controllers ──
  final _addressCtrl = TextEditingController();

  // ── พิกัด + ที่อยู่จาก map ──
  double? selectedLat;
  double? selectedLng;
  String selectedProvince = '';
  String selectedDistrict = '';
  String selectedSubDistrict = '';

  // ─── AppBar ───────────────────────────────────────────────────────────────
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
                'แก้ไขที่อยู่',
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
        preferredSize: const ui.Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── โหลดข้อมูลเดิมจาก provider ──────────────────────────────────────────
  void _loadInitialData() {
    final farmer = Provider.of<DataFarmers>(context, listen: false).datauser;

    setState(() {
      selectedProvince = farmer.farmersProvince ?? '';
      selectedDistrict = farmer.farmersDistrict ?? '';
      selectedSubDistrict = farmer.farmersLocality ?? '';
      selectedLat = farmer.farmersLocLat != null
          ? double.tryParse(farmer.farmersLocLat!)
          : null;
      selectedLng = farmer.farmersLocLong != null
          ? double.tryParse(farmer.farmersLocLong!)
          : null;
      _addressCtrl.text = farmer.farmersAddress ?? '';
    });
  }

  // ── เปิด MapPickerPage ────────────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          googleApiKey: _googleApiKey,
          initialLat: selectedLat,
          initialLng: selectedLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLat = result.lat;
        selectedLng = result.lng;
        selectedProvince = result.province;
        selectedDistrict = result.district;
        selectedSubDistrict = result.subDistrict;
        if (_addressCtrl.text.isEmpty && result.addressDetail.isNotEmpty) {
          _addressCtrl.text = result.addressDetail;
        }
      });
    }
  }

  // ── บันทึก ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedLat == null) {
      _showErrorDialog('กรุณาเลือกตำแหน่งที่อยู่บนแผนที่');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final farmerId =
          Provider.of<DataFarmers>(context, listen: false).datauser.farmersId;

      final res = await http.put(
        Uri.parse('$apiEndpoint/farmer/update-address/$farmerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farmers_province': selectedProvince,
          'farmers_district': selectedDistrict,
          'farmers_locality': selectedSubDistrict,
          'farmers_address': _addressCtrl.text.trim(),
          'farmers_loc_lat': selectedLat,
          'farmers_loc_long': selectedLng,
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        await Provider.of<DataFarmers>(context, listen: false)
            .fetchFarmerById(farmerId);
        //_showSnackbar('บันทึกที่อยู่สำเร็จ ✓', Colors.green);
        _showSuccessDialog('ระบบได้อัปเดตที่อยู่ของคุณเรียบร้อยแล้ว');
        Navigator.pop(context);
      } else {
        final body = jsonDecode(res.body);
        _showSnackbar(body['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Snackbar / Dialog ─────────────────────────────────────────────────────
  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.notoSansThai(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('เกิดข้อผิดพลาด',
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ตกลง', style: GoogleFonts.notoSansThai(color: _green)),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6, left: 20, right: 20),
        child: Row(
          children: [
            Icon(icon, size: 15, color: _green),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _green,
                    letterSpacing: 0.5)),
            const SizedBox(width: 8),
            const Expanded(child: Divider(color: _border, thickness: 1)),
          ],
        ),
      );

  /// ปุ่มเปิดแผนที่ + summary card
  Widget _buildLocationPicker() {
    final hasPicked = selectedLat != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ตำแหน่งที่อยู่',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 13, color: _labelColor)),
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),

          // ปุ่มเปิดแผนที่
          GestureDetector(
            onTap: _openMapPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: hasPicked ? _greenLight : Colors.white,
                border: Border.all(
                  color: hasPicked ? _green : _border,
                  width: hasPicked ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    hasPicked ? Icons.location_on : Icons.location_on_outlined,
                    color: hasPicked ? _green : _labelColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasPicked
                          ? 'lat: ${selectedLat!.toStringAsFixed(5)},  lng: ${selectedLng!.toStringAsFixed(5)}'
                          : 'แตะเพื่อค้นหาหรือเลือกตำแหน่งบนแผนที่',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        color: hasPicked ? _green : _labelColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _labelColor, size: 18),
                ],
              ),
            ),
          ),

          // Address summary card
          if (hasPicked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _addressRow('จังหวัด', selectedProvince),
                  _addressRow('อำเภอ', selectedDistrict),
                  _addressRow('ตำบล', selectedSubDistrict),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── เพิ่ม method นี้ ──
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('แก้ไขที่อยู่สำเร็จ ✓',
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context), // ปิด dialog แล้วกลับหน้าเดิม
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('ตกลง',
                style: GoogleFonts.notoSansThai(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) => Navigator.pop(context)); // ปิด page หลัง dialog ปิด
  }

  Widget _addressRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text('$label:',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 12, color: _labelColor)),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : '—',
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildAddressField() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ที่อยู่เพิ่มเติม',
                style:
                    GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              style: GoogleFonts.notoSansThai(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'บ้านเลขที่, หมู่, ถนน',
                hintStyle:
                    GoogleFonts.notoSansThai(color: _labelColor, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _green, width: 1.5)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: _green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'เลือกตำแหน่งบนแผนที่เพื่ออัปเดตที่อยู่ของคุณให้แม่นยำ',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 12, color: _green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ที่อยู่ ──
              _sectionHeader('ที่อยู่', Icons.home_outlined),
              _buildLocationPicker(),
              _buildAddressField(),

              const SizedBox(height: 40),

              // ── ปุ่มบันทึก ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('บันทึกที่อยู่',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
