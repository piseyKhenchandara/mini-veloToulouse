import 'package:flutter/material.dart';
import 'package:mini_velo/model/plan.dart';

class PlanPanel extends StatelessWidget {
  final Plan plan;
  final bool isActive;
  final bool isSelected;

  const PlanPanel({
    super.key,
    required this.plan,
    this.isActive = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isSelected ? Colors.green.withOpacity(0.15) : Colors.grey[100],

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TOP ROW
          Row(
            children: [
              Image.asset(
                'assets/images/ticket.png',
                width: 60,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.confirmation_number, size: 40),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  _formatName(plan.planName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (isActive) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 DESCRIPTION
          Text(
            _getDescription(plan.time),
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // 🔹 BOTTOM ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTimeText(plan.time),
                style: const TextStyle(fontSize: 14),
              ),

              Text(
                "\$${plan.price}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 helper: format name
  String _formatName(String name) {
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

  // 🔹 helper: description
  String _getDescription(int time) {
    if (time == 0) return "One ride only";
    if (time == 24) return "Full day access";
    if (time == 168) return "Full week access";
    if (time == 720) return "Full month access";
    return "$time days access";
  }

  // 🔹 helper: time text
  String _getTimeText(int time) {
    if (time == 0) return "1 Ride";
    return "${time * 24} hrs";
  }
}
