import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MiniMap extends StatefulWidget {
  final double lat;
  final double lng;
  const MiniMap({super.key, required this.lat, required this.lng});

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  MapboxMap? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _controller = controller;

    // ปิด gesture ทั้งหมด
    await controller.gestures.updateSettings(GesturesSettings(
      scrollEnabled:            false,
      rotateEnabled:            false,
      pinchToZoomEnabled:       false,
      doubleTapToZoomInEnabled: false,
      quickZoomEnabled:         false,
      pitchEnabled:             false,
    ));

    // ซ่อน UI controls
    await controller.logo.updateSettings(LogoSettings(enabled: false));
    await controller.attribution
        .updateSettings(AttributionSettings(enabled: false));
    await controller.compass.updateSettings(CompassSettings(enabled: false));
    await controller.scaleBar
        .updateSettings(ScaleBarSettings(enabled: false));

    // วาง marker เข็มหมุด
    final manager =
        await controller.annotations.createPointAnnotationManager();

    await manager.create(PointAnnotationOptions(
      geometry:   Point(coordinates: Position(widget.lng, widget.lat)),
      image:      await _buildPinImage(),
      iconAnchor: IconAnchor.BOTTOM, // ปลายเข็มอยู่ที่พิกัด
      iconSize:   1.0,
    ));
  }

  // ── วาดเข็มหมุดด้วย Canvas ──────────────────────────────────
  Future<Uint8List> _buildPinImage({
    Color pinColor   = const Color(0xFFE53935),
    Color dotColor   = Colors.white,
    double width     = 48,
    double height    = 64,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    final cx    = width / 2;
    final bodyR = width / 2 - 3; // รัศมีวงกลมหัวเข็ม

    canvas.drawCircle(
      Offset(cx + 1, bodyR + 2),
      bodyR,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );


    final tailPath = Path()
      ..moveTo(cx - 8, bodyR * 2 - 2)
      ..lineTo(cx,     height)
      ..lineTo(cx + 8, bodyR * 2 - 2)
      ..close();

    canvas.drawPath(tailPath, Paint()..color = pinColor);

    // ขอบหาง
    canvas.drawPath(
      tailPath,
      Paint()
        ..color       = Colors.white
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      Offset(cx, bodyR),
      bodyR,
      Paint()..color = pinColor,
    );

    // ขอบวงกลม
    canvas.drawCircle(
      Offset(cx, bodyR),
      bodyR,
      Paint()
        ..color       = Colors.white
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );


    canvas.drawCircle(
      Offset(cx - bodyR * 0.22, bodyR - bodyR * 0.28),
      bodyR * 0.36,
      Paint()..color = Colors.white.withOpacity(0.32),
    );

    canvas.drawCircle(
      Offset(cx, bodyR),
      bodyR * 0.28,
      Paint()..color = dotColor,
    );


    final picture = recorder.endRecording();
    final image   = await picture.toImage(width.toInt(), height.toInt());
    final bytes   = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => MapWidget(
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(widget.lng, widget.lat)),
          zoom:   14.0,
        ),
        styleUri:     MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,
      );
}