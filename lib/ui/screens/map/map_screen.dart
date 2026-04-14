import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../config/map_config.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../model/station.dart';
import '../../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final StationRepository _repository = StationRepository();

  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final stations = await _repository.fetchAll();
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBar(),
          /* _buildReleaseButton(), */
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(MapConfig.defaultLat, MapConfig.defaultLng),
        initialZoom: MapConfig.defaultZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.mini_velo',
        ),
        MarkerLayer(
          markers: _stations
              .map((s) => Marker(
                    point: LatLng(s.lat, s.lng),
                    width: 72,
                    height: 52,
                    child: _StationBubble(bikeCount: s.availableBikes),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search Station',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseButton() {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Release a bike',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _StationBubble extends StatelessWidget {
  final int bikeCount;

  const _StationBubble({required this.bikeCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            '$bikeCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CustomPaint(
          painter: _TrianglePainter(),
          size: const Size(12, 8),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}
