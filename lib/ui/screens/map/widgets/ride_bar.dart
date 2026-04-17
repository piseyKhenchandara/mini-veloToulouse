import 'package:flutter/material.dart';

import '../../../../model/active_ride.dart';

class RideBar extends StatelessWidget {
  final ActiveRide ride;
  final Duration duration;

  const RideBar({super.key, required this.ride, required this.duration});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${minutes}mn ${seconds}sec';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bike, color: Colors.black87, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'BikeId: ${ride.bikeNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const Icon(Icons.timer_outlined, color: Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              _formatDuration(duration),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
