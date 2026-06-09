import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MiniMap extends StatefulWidget {
  final double lat;
  final double lng;
  final String apiKey;

  const MiniMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.apiKey,
  });

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(widget.lat, widget.lng),
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://mt0.google.com/vt/lyrs=m&hl=th&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.example.cow_booking',
          tileDisplay: const TileDisplay.instantaneous(opacity: 1.0),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(widget.lat, widget.lng),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
