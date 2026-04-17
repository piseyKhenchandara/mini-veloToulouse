import 'dart:async';
import 'package:flutter/material.dart';

class ActivePlanBanner extends StatefulWidget {
  final String planName;
  final DateTime? expiresAt;

  const ActivePlanBanner({super.key, required this.planName, this.expiresAt});

  @override
  State<ActivePlanBanner> createState() => _ActivePlanBannerState();
}

class _ActivePlanBannerState extends State<ActivePlanBanner> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.expiresAt == null) return;
    final now = DateTime.now().toUtc();
    final diff = widget.expiresAt!.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatPlanName(String name) {
    switch (name) {
      case "perRide":
        return "Pay Per Ride";
      case "daily":
        return "Daily Pass";
      case "weekly":
        return "Weekly Pass";
      case "monthly":
        return "Monthly Pass";
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPerRide = widget.expiresAt == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Active: ${_formatPlanName(widget.planName)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPerRide
                      ? "Charged per ride"
                      : _remaining == Duration.zero
                      ? "Expired"
                      : "Expires in ${_format(_remaining)}",
                  style: TextStyle(
                    color: _remaining == Duration.zero && !isPerRide
                        ? Colors.red
                        : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
