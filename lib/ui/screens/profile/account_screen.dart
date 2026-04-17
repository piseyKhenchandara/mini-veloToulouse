import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../subscription/plan_view_model.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String _userId = "9e2536f0-d025-420c-9112-ec279dc6b146";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final planVm = context.read<PlanViewModel>();
      planVm.fetchUserPlan(_userId);
    });
  }

  String _formatPlanName(String planName) {
    switch (planName) {
      case 'per_ride':
        return 'Pay Per Ride';
      case 'daily':
        return 'Daily Pass';
      case 'weekly':
        return 'Weekly Pass';
      case 'monthly':
        return 'Monthly Pass';
      default:
        return planName;
    }
  }

  String _getTimeLeft(PlanViewModel planVm) {
    if (planVm.expiresAt == null) return 'No Plan';
    final now = DateTime.now();
    final remaining = planVm.expiresAt!.difference(now);
    
    if (remaining.isNegative) return 'Expired';
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d Left';
    } else if (hours > 0) {
      return '${hours}h Left';
    } else {
      return '${minutes}m Left';
    }
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<PlanViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔹 TITLE
              const Text(
                "USER PROFILE",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 AVATAR
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),

              const SizedBox(height: 20),

              // 🔹 CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔸 LEFT CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ronan the best",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            planVm.activePlan != null
                                ? "Active Plan: ${_formatPlanName(planVm.activePlan!.planName)}"
                                : "Active Plan: None",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Rides: ${planVm.totalRides} times',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Duration: ${planVm.totalDurationText}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 🔸 RIGHT BADGE
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.percent, color: Colors.green, size: 30),
                          const SizedBox(height: 6),
                          Text(
                            _getTimeLeft(planVm),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
