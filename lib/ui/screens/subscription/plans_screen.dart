import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/active_plan_banner.dart';
import '../../widgets/payment_confirm_sheet.dart';
import 'plan_panel.dart';
import 'plan_view_model.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = "9e2536f0-d025-420c-9112-ec279dc6b146";
      final vm = context.read<PlanViewModel>();
      vm.init(userId);
        });
  }

  void _showPaymentSheet(BuildContext context, PlanViewModel vm, plan) {
    final userId = "9e2536f0-d025-420c-9112-ec279dc6b146";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentConfirmSheet(
        plan: plan,
        onConfirm: () async {
          Navigator.pop(context); // close sheet
          final success = await vm.buyPlan(userId, plan);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Plan activated!'
                      : 'Purchase failed. Try again.',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${vm.error}')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 50),

          const Text(
            "SUBSCRIPTION",
            style: TextStyle(
              color: Colors.green,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 active plan banner with countdown
          if (vm.activePlan != null)
            ActivePlanBanner(
              planName: vm.activePlan!.planName,
              expiresAt: vm.expiresAt,
            ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: vm.plans.length,
                itemBuilder: (context, index) {
                  final plan = vm.plans[index];
                  final isActive = vm.activePlan?.planName == plan.planName;
                  final isSelected = vm.selectedPlan?.planName == plan.planName;

                  return GestureDetector(
                    onTap: () => vm.selectPlan(plan),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: PlanPanel(
                                plan: plan,
                                isActive: isActive,
                                isSelected: isSelected,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: isActive
                                  ? null
                                  : () => _showPaymentSheet(context, vm, plan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isActive
                                    ? Colors.grey
                                    : AppColors.primary,
                              ),
                              child: Text(isActive ? "Active" : "Buy"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
