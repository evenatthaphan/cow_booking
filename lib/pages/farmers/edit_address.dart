import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/Home/map_picker_page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
  bool _isLoading    = false;
  bool _isSaving     = false;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _border = Color(0xFFD8EDD8);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _labelColor = Color(0xFF757575);

  // Controllers
  final _addressCtrl    = TextEditingController();
  final _provinceCtrl   = TextEditingController();
  final _districtCtrl   = TextEditingController();
  final _subdistrictCtrl = TextEditingController();


  List _provinces    = [];
  List _districts    = [];
  List _subDistricts = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubDistrict;


  double? _lat;
  double? _lng;

  static const _greenLight = Color(0xFFE8F5E9);

   // ── helper: แปลง String? → double? ──────────────────────────
  double? _parseCoord(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    return double.tryParse(val.trim());
  }

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
        child: Container(
            height: 1, color: Colors.white.withOpacity(0.1)),
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
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _subdistrictCtrl.dispose();
    super.dispose();
  }

  // โหลดข้อมูลเดิม + provinces 
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // โหลด provinces จาก API
      final res = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province_with_district_and_sub_district.json",
      ));

      if (res.statusCode == 200) {
        final farmer = Provider.of<DataFarmers>(context, listen: false).datauser;
        final pList  = jsonDecode(res.body) as List;

        // เติมข้อมูลเดิม
        _addressCtrl.text = farmer.farmersAddress;
        _lat = farmer.farmersLocLat != null ? double.tryParse(farmer.farmersLocLat!) : null;
        _lng = farmer.farmersLocLong != null ? double.tryParse(farmer.farmersLocLong!) : null;

        // หา province ที่ตรง
        final matchProvince = pList.where(
          (p) => p['name_th'] == farmer.farmersProvince,
        ).toList();

        List dList = [];
        List sList = [];
        String? selProv;
        String? selDist;
        String? selSub;

        if (matchProvince.isNotEmpty) {
          selProv = farmer.farmersProvince;
          dList   = matchProvince[0]['districts'] ?? [];

          final matchDistrict = dList.where(
            (d) => d['name_th'] == farmer.farmersDistrict,
          ).toList();

          if (matchDistrict.isNotEmpty) {
            selDist = farmer.farmersDistrict;
            sList   = matchDistrict[0]['sub_districts'] ?? [];

            final matchSub = sList.where(
              (s) => s['name_th'] == farmer.farmersLocality,
            ).toList();

            if (matchSub.isNotEmpty) selSub = farmer.farmersLocality;
          }
        }

        setState(() {
          _provinces          = pList;
          _districts          = dList;
          _subDistricts       = sList;
          _selectedProvince   = selProv;
          _selectedDistrict   = selDist;
          _selectedSubDistrict = selSub;
          _provinceCtrl.text  = selProv ?? '';
          _districtCtrl.text  = selDist ?? '';
          _subdistrictCtrl.text = selSub ?? '';
        });
      }
    } catch (e) {
      debugPrint('load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // บันทึก 
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null) {
      _showSnackbar('กรุณาเลือกตำแหน่งบนแผนที่', Colors.red);
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
          'farmers_province':  _selectedProvince ?? '',
          'farmers_district':  _selectedDistrict ?? '',
          'farmers_locality':  _selectedSubDistrict ?? '',
          'farmers_address':   _addressCtrl.text.trim(),
          'farmers_loc_lat':   _lat,
          'farmers_loc_long':  _lng,
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        // refresh Provider
        await Provider.of<DataFarmers>(context, listen: false)
            .fetchFarmerById(farmerId);
        _showSnackbar('บันทึกที่อยู่สำเร็จ ✓', Colors.green);
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

  // ── Tab: ที่อยู่ + Mini map ───────────────────────────────────
  Widget _mapAddress() {
    return Consumer<DataFarmers>(
      builder: (_, dataFarmer, __) {
        final farmer = dataFarmer.datauser;

        // แปลง String? → double?
        final double? lat = _parseCoord(farmer.farmersLocLat);
        final double? lng = _parseCoord(farmer.farmersLocLong);
        final bool hasCoords = lat != null && lng != null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mini map ────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 220,
                  child: hasCoords
                      ? _MiniMap(lat: lat, lng: lng)
                      : _NoMapPlaceholder(),
                ),
              ),
              const SizedBox(height: 16),

              // ── ที่อยู่ card ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(Icons.location_on_outlined,
                          color: _green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.farmersAddress.isNotEmpty
                                ? farmer.farmersAddress
                                : 'ไม่ระบุที่อยู่',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 14, color: _textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [farmer.farmersProvince, farmer.farmersDistrict, farmer.farmersLocality]
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                            style: GoogleFonts.notoSansThai(
                                fontSize: 13, color: _labelColor),
                          ),
                          if (hasCoords) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _lightGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.gps_fixed,
                                      size: 12, color: _green),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                                    style: GoogleFonts.notoSansThai(
                                        fontSize: 11, color: _green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // แผนที่ปัจจุบัน 
                    _sectionHeader('ตำแหน่งที่อยู่', Icons.location_on_outlined),
                    _mapAddress(),
                    _buildLocationPicker(),

                    // จังหวัด / อำเภอ / ตำบล 
                    _sectionHeader('ที่อยู่', Icons.home_outlined),
                    _buildDropdown(
                      label: 'จังหวัด',
                      value: _selectedProvince,
                      items: _provinces,
                      onChanged: (val) {
                        setState(() {
                          _selectedProvince    = val;
                          _selectedDistrict    = null;
                          _selectedSubDistrict = null;
                          _provinceCtrl.text   = val ?? '';
                          _districtCtrl.text   = '';
                          _subdistrictCtrl.text = '';
                          final p = _provinces.firstWhere(
                              (p) => p['name_th'] == val, orElse: () => {});
                          _districts    = p['districts'] ?? [];
                          _subDistricts = [];
                        });
                      },
                    ),
                    _buildDropdown(
                      label: 'อำเภอ',
                      value: _selectedDistrict,
                      items: _districts,
                      enabled: _districts.isNotEmpty,
                      onChanged: (val) {
                        setState(() {
                          _selectedDistrict    = val;
                          _selectedSubDistrict = null;
                          _districtCtrl.text   = val ?? '';
                          _subdistrictCtrl.text = '';
                          final d = _districts.firstWhere(
                              (d) => d['name_th'] == val, orElse: () => {});
                          _subDistricts = d['sub_districts'] ?? [];
                        });
                      },
                    ),
                    _buildDropdown(
                      label: 'ตำบล',
                      value: _selectedSubDistrict,
                      items: _subDistricts,
                      enabled: _subDistricts.isNotEmpty,
                      onChanged: (val) {
                        setState(() {
                          _selectedSubDistrict  = val;
                          _subdistrictCtrl.text  = val ?? '';
                        });
                      },
                    ),
                    _buildField(
                      label: 'ที่อยู่เพิ่มเติม (บ้านเลขที่, หมู่, ถนน)',
                      controller: _addressCtrl,
                      required: true,
                    ),

                    // ปุ่มบันทึก 
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20, height: 20,
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

  // แผนที่ปัจจุบัน
  Widget _buildLocationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapPickerPage()),
          );
          if (result != null) {
            setState(() {
              _lat = result['lat'];
              _lng = result['lng'];
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _lat != null ? _greenLight : Colors.white,
            border: Border.all(
              color: _lat != null ? _green : _border,
              width: _lat != null ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _lat != null ? Icons.location_on : Icons.location_on_outlined,
                color: _lat != null ? _green : _labelColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _lat != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ตำแหน่งที่เลือก',
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 11, color: _green)),
                          Text(
                            'lat: ${_lat!.toStringAsFixed(5)},  lng: ${_lng!.toStringAsFixed(5)}',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _green),
                          ),
                        ],
                      )
                    : Text(
                        'แตะเพื่อเลือกตำแหน่งบนแผนที่',
                        style: GoogleFonts.notoSansThai(
                            fontSize: 13, color: _labelColor),
                      ),
              ),
              Icon(Icons.chevron_right, color: _labelColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 13, color: _labelColor)),
                if (required)
                  const Text(' *',
                      style: TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.notoSansThai(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _green, width: 1.5)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: required
                  ? (v) => (v == null || v.isEmpty) ? 'กรุณากรอก$label' : null
                  : null,
            ),
          ],
        ),
      );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 13, color: _labelColor)),
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              style: GoogleFonts.notoSansThai(
                  fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _green, width: 1.5)),
                filled: true,
                fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
              ),
              items: items.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem(
                  value: item['name_th'] as String,
                  child: Text(item['name_th'] as String,
                      style: GoogleFonts.notoSansThai(fontSize: 14)),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'กรุณาเลือก$label' : null,
            ),
          ],
        ),
      );
}

// ── Mini map (Mapbox) ─────────────────────────────────────────
class _MiniMap extends StatefulWidget {
  final double lat;
  final double lng;
  const _MiniMap({required this.lat, required this.lng});

  @override
  State<_MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<_MiniMap> {
  MapboxMap? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _controller = controller;

    // ปิด gesture ทั้งหมด (mini map ไม่ให้เลื่อน)
    await controller.gestures.updateSettings(GesturesSettings(
      scrollEnabled: false,
      rotateEnabled: false,
      pinchToZoomEnabled: false,
      doubleTapToZoomInEnabled: false,
      quickZoomEnabled: false,
      pitchEnabled: false,
    ));

    // ซ่อน UI controls
    await controller.logo.updateSettings(LogoSettings(enabled: false));
    await controller.attribution
        .updateSettings(AttributionSettings(enabled: false));
    await controller.compass.updateSettings(CompassSettings(enabled: false));
    await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // วาง marker
    final manager = await controller.annotations.createPointAnnotationManager();
    await manager.create(PointAnnotationOptions(
      geometry: Point(coordinates: Position(widget.lng, widget.lat)),
      iconImage: 'marker-15',
      iconSize: 2.0,
      iconColor: 0xFFE53935,
    ));
  }

  @override
  Widget build(BuildContext context) => MapWidget(
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(widget.lng, widget.lat)),
          zoom: 14.0,
        ),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,
      );
}

// ── Placeholder เมื่อไม่มีพิกัด ───────────────────────────────
class _NoMapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFF1F3F4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('ไม่มีข้อมูลพิกัด',
                style: GoogleFonts.notoSansThai(
                    fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      );
}