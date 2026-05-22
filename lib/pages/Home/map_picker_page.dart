// map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  MapboxMap? _mapboxMap;
  double? selectedLat;
  double? selectedLng;

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
                'เลือกตำแหน่งที่อยู่ของคุณ',
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


  // ค่าเริ่มต้น: กลางประเทศไทย
  final CameraOptions _initialCamera = CameraOptions(
    center: Point(coordinates: Position(100.5018, 13.7563)), // กรุงเทพฯ
    zoom: 6.0,
  );

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    // รับ event เมื่อแตะแผนที่
    mapboxMap.setOnMapTapListener((MapContentGestureContext context) {
      final coord = context.point.coordinates;
      setState(() {
        selectedLat = coord.lat.toDouble();
        selectedLng = coord.lng.toDouble();
      });

      // วาง Marker จุดที่แตะ
      _addMarker(coord.lng.toDouble(), coord.lat.toDouble());
    });
  }

  Future<void> _addMarker(double lng, double lat) async {
    if (_mapboxMap == null) return;

    final annotationManager =
        await _mapboxMap!.annotations.createPointAnnotationManager();

    await annotationManager.deleteAll();

    await annotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        iconSize: 1.5,
        iconImage: "marker-15", // built-in icon
      ),
    );

    // เลื่อนกล้องไปจุดที่แตะ
    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 14.0,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          MapWidget(
            cameraOptions: _initialCamera,
            onMapCreated: _onMapCreated,
          ),

          // แสดง lat/lng ที่เลือก
          if (selectedLat != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: Text(
                  'lat: ${selectedLat!.toStringAsFixed(6)}\nlng: ${selectedLng!.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),

          // ปุ่มยืนยัน
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: selectedLat == null
                  ? null
                  : () {
                      Navigator.of(context)
                          .pop({'lat': selectedLat, 'lng': selectedLng});
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('ยืนยันตำแหน่ง',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}