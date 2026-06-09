import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

/// ผลลัพธ์ที่ส่งกลับไปยัง FarmerRegister
class MapPickerResult {
  final double lat;
  final double lng;
  final String province;      // จังหวัด
  final String district;      // อำเภอ
  final String subDistrict;   // ตำบล
  final String addressDetail; // ที่อยู่เพิ่มเติม (เลขที่ถนน ฯลฯ)

  const MapPickerResult({
    required this.lat,
    required this.lng,
    required this.province,
    required this.district,
    required this.subDistrict,
    required this.addressDetail,
  });
}

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  /// Google Maps API key – ใช้เฉพาะ Places Autocomplete (search bar)
  final String googleApiKey;

  const MapPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.googleApiKey,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  static const _defaultPosition = LatLng(13.7563, 100.5018);
  LatLng _pickedLatLng = _defaultPosition;
  final Set<Marker> _markers = {};

  bool _loadingAddress = false;
  String _province    = '';
  String _district    = '';
  String _subDistrict = '';
  String _detail      = '';

  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  List<_Suggestion> _suggestions = [];
  Timer? _debounce;
  bool _searchLoading = false;

  static const _green      = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pickedLatLng = LatLng(widget.initialLat!, widget.initialLng!);
      _updateMarker(_pickedLatLng);
      _reverseGeocode(_pickedLatLng);
    } else {
      _updateMarker(_pickedLatLng);
      _locateMe();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _locateMe() async {
    try {
      final loc = Location();

      bool serviceEnabled = await loc.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await loc.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus perm = await loc.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await loc.requestPermission();
        if (perm != PermissionStatus.granted) return;
      }
      if (perm == PermissionStatus.deniedForever) return;

      final data = await loc.getLocation();
      if (!mounted) return;
      if (data.latitude == null || data.longitude == null) return;

      final latLng = LatLng(data.latitude!, data.longitude!);
      _pickedLatLng = latLng;
      _updateMarker(latLng);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)),
      );
      _reverseGeocode(latLng);
    } catch (_) {
      // silent
    }
  }

  void _updateMarker(LatLng pos) {
    setState(() {
      _markers
        ..clear()
        ..add(Marker(
          markerId: const MarkerId('picked'),
          position: pos,
          draggable: true,
          onDragEnd: (newPos) {
            _pickedLatLng = newPos;
            _reverseGeocode(newPos);
          },
        ));
    });
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    if (!mounted) return;
    setState(() => _loadingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${pos.latitude}&lon=${pos.longitude}'
        '&format=json&accept-language=th&addressdetails=1',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'Cowbooking/1.0',
      });
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = (data['address'] as Map<String, dynamic>?) ?? {};

        // ── Debug: ดู key ทั้งหมดที่ Nominatim คืนมา ──
        print('=== Nominatim address keys ===');
        addr.forEach((k, v) => print('  $k: $v'));

        setState(() {
          _province    = _parseProvince(addr);
          _district    = _parseDistrict(addr);
          _subDistrict = _parseSubDistrict(addr);
          _detail      = _parseDetail(addr);
        });
      }
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  /// จังหวัด — Nominatim ไทยใช้ 'state' หรือ 'province' เป็นหลัก
  String _parseProvince(Map<String, dynamic> addr) {
    final raw = (addr['province']     as String? ??
                 addr['state']        as String? ?? '').trim();
    return _cleanThai(raw);
  }

  /// อำเภอ — ลอง county → city_district → city → town
  String _parseDistrict(Map<String, dynamic> addr) {
    final candidates = [
      addr['county']         as String? ?? '',
      addr['city_district']  as String? ?? '',
      addr['city']           as String? ?? '',
      addr['town']           as String? ?? '',
      addr['municipality']   as String? ?? '',
    ];
    final raw = candidates.firstWhere((s) => s.isNotEmpty, orElse: () => '');
    return _cleanThai(raw);
  }

  /// ตำบล — ลอง suburb → quarter → village → hamlet → neighbourhood
  String _parseSubDistrict(Map<String, dynamic> addr) {
    final candidates = [
      addr['suburb']         as String? ?? '',
      addr['quarter']        as String? ?? '',
      addr['village']        as String? ?? '',
      addr['hamlet']         as String? ?? '',
      addr['neighbourhood']  as String? ?? '',
      addr['residential']    as String? ?? '',
    ];
    final raw = candidates.firstWhere((s) => s.isNotEmpty, orElse: () => '');

    // กันซ้ำกับ district
    final cleaned = _cleanThai(raw);
    return (cleaned == _district) ? '' : cleaned;
  }

  /// ถนน / เลขที่
  String _parseDetail(Map<String, dynamic> addr) {
    final parts = [
      addr['house_number'] as String? ?? '',
      addr['road']         as String? ?? '',
      addr['pedestrian']   as String? ?? '',
      addr['footway']      as String? ?? '',
    ].where((s) => s.isNotEmpty).toList();
    return parts.join(' ');
  }

  /// ตัด prefix ภาษาไทย/อังกฤษที่ไม่ต้องการออก
  String _cleanThai(String s) {
    return s
        .replaceFirst(RegExp(r'^จังหวัด\s*'), '')
        .replaceFirst(RegExp(r'^อำเภอ\s*'), '')
        .replaceFirst(RegExp(r'^เขต\s*'), '')
        .replaceFirst(RegExp(r'^ตำบล\s*'), '')
        .replaceFirst(RegExp(r'^แขวง\s*'), '')
        .replaceFirst(RegExp(
            r'^(Chang Wat|Amphoe|Khet|Tambon|Khwaeng)\s*',
            caseSensitive: false), '')
        .trim();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    if (text.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _fetchSuggestions(text),
    );
  }

  Future<void> _fetchSuggestions(String input) async {
    setState(() => _searchLoading = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&language=th'
        '&components=country:th'
        '&key=${widget.googleApiKey}',
      );
      final res = await http.get(url);
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        final predictions = data['predictions'] as List? ?? [];
        setState(() {
          _suggestions = predictions
              .map((p) => _Suggestion(
                    placeId:     p['place_id']   as String,
                    description: p['description'] as String,
                  ))
              .toList();
        });
      }
    } catch (_) {
      // silent
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  /// เมื่อเลือกสถานที่จาก autocomplete → ดึง lat/lng แล้ว reverse geocode ด้วย Nominatim
  Future<void> _selectSuggestion(_Suggestion s) async {
    _searchFocus.unfocus();
    setState(() {
      _suggestions   = [];
      _searchCtrl.text = s.description;
    });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${s.placeId}'
        '&fields=geometry'           // ขอแค่ geometry ประหยัด quota
        '&key=${widget.googleApiKey}',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body);
        final loc    = data['result']['geometry']['location'];
        final pos    = LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );
        _pickedLatLng = pos;
        _updateMarker(pos);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 16)),
        );
        // ใช้ Nominatim แทน address_components ของ Google
        await _reverseGeocode(pos);
      }
    } catch (_) {
      // silent
    }
  }

  void _onMapTap(LatLng pos) {
    _searchFocus.unfocus();
    setState(() => _suggestions = []);
    _pickedLatLng = pos;
    _updateMarker(pos);
    _reverseGeocode(pos);
  }

  void _confirm() {
    Navigator.pop(
      context,
      MapPickerResult(
        lat:           _pickedLatLng.latitude,
        lng:           _pickedLatLng.longitude,
        province:      _province,
        district:      _district,
        subDistrict:   _subDistrict,
        addressDetail: _detail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'เลือกตำแหน่งที่อยู่',
          style: GoogleFonts.notoSansThai(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _pickedLatLng, zoom: 15),
            onMapCreated: (c) => _mapController = c,
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          Positioned(
            top: 12, left: 12, right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.notoSansThai(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาสถานที่...',
                      hintStyle: GoogleFonts.notoSansThai(
                          fontSize: 14, color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: _green),
                      suffixIcon: _searchLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _green),
                              ),
                            )
                          : _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _suggestions = []);
                                  },
                                )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on_outlined,
                                color: _green, size: 18),
                            title: Text(
                              s.description,
                              style: GoogleFonts.notoSansThai(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(s),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _loadingAddress
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _green),
                          ),
                        )
                      : _AddressCard(
                          province:    _province,
                          district:    _district,
                          subDistrict: _subDistrict,
                          detail:      _detail,
                          lat:         _pickedLatLng.latitude,
                          lng:         _pickedLatLng.longitude,
                        ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 18),
                      label: Text(
                        'ยืนยันตำแหน่งนี้',
                        style: GoogleFonts.notoSansThai(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final String placeId;
  final String description;
  const _Suggestion({required this.placeId, required this.description});
}

class _AddressCard extends StatelessWidget {
  final String province;
  final String district;
  final String subDistrict;
  final String detail;
  final double lat;
  final double lng;

  static const _green      = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);

  const _AddressCard({
    required this.province,
    required this.district,
    required this.subDistrict,
    required this.detail,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: _green, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(label: 'จังหวัด', value: province),
                _Row(label: 'อำเภอ',   value: district),
                _Row(label: 'ตำบล',    value: subDistrict),
                if (detail.isNotEmpty)
                  _Row(label: 'ที่อยู่', value: detail),
                const SizedBox(height: 4),
                Text(
                  'lat ${lat.toStringAsFixed(6)}  lng ${lng.toStringAsFixed(6)}',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  static const _green = Color(0xFF2E7D32);

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              '$label:',
              style: GoogleFonts.notoSansThai(
                  fontSize: 12, color: Colors.grey[600]),
            ),
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
  }
}