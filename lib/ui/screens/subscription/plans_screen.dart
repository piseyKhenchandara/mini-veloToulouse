import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
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

    Future.microtask(() async {
      //final userId = Supabase.instance.client.auth.currentUser?.id;
      final userId = "9e2536f0-d025-420c-9112-ec279dc6b146";
      final vm = context.read<PlanViewModel>();

      // if (userId != null) {
      //   await vm.init(userId); // loads plans + active plan
      // } else {
      //   await vm.fetchAllPlans(); // loads plans only
      // }
      await vm.init(userId); // loads plans + active plan
    });
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
                    onTap: () {
                      vm.selectPlan(plan);
                    },

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
                                  : () {
                                      vm.selectPlan(plan);
                                      // 👉 later: call buy API here
                                    },

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
