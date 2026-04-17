import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/bike.dart';
import '../../theme/app_colors.dart';
import '../../widgets/payment_confirm_sheet.dart';
import 'station_detail_view_model.dart';
import '../subscription/plan_view_model.dart';
import '../map/map_view_model.dart';

class StationDetailPanel extends StatelessWidget {
  const StationDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StationDetailViewModel>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // station name + close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    vm.station.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.read<MapViewModel>().closePanel(),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.dock, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Total: ${vm.station.totalDocks} Bikes',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const Spacer(),
                if (vm.distanceText != null) ...[
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${vm.distanceText} away',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // availability box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${vm.availableCount} / ${vm.station.totalDocks} Available Bikes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // hint text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap a bike to start your ride',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          // ride error
          if (vm.rideError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Failed to start ride: ${vm.rideError}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          const SizedBox(height: 8),
          // bike list
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (vm.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${vm.error}',
                  style: const TextStyle(color: Colors.red)),
            )
          else
            Flexible(
              child: _BikePanelList(
                bikes: vm.bikes,
                isStartingRide: vm.isStartingRide,  // Disables taps while starting
                onBikeTap: (bike) async {
                  final mapVm = context.read<MapViewModel>();
                  final detailVm = context.read<StationDetailViewModel>();
                  final planVm = context.read<PlanViewModel>();

                  // Check if user has Pay Per Ride plan active
                  if (planVm.activePlan != null && planVm.activePlan?.planName == "per_ride") {
                    // Get the Pay Per Ride plan from all plans
                    try {
                      final payPerRidePlan = planVm.plans
                          .firstWhere((p) => p.planName == "per_ride");
                      final userId = "9e2536f0-d025-420c-9112-ec279dc6b146";
                      
                      if (context.mounted) {
                        // Show payment sheet
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => PaymentConfirmSheet(
                            plan: payPerRidePlan,
                            onConfirm: () async {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              
                              final success =
                                  await planVm.buyPlan(userId, payPerRidePlan);
                              
                              if (!context.mounted) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Plan activated!'
                                        : 'Purchase failed. Try again.',
                                  ),
                                  backgroundColor:
                                      success ? Colors.green : Colors.red,
                                ),
                              );
                              
                              // If payment successful, proceed with renting the bike
                              if (success && context.mounted) {
                                final ride = await detailVm.startRide(bike);
                                if (ride != null && context.mounted) {
                                  mapVm.onRideStarted(ride);
                                }
                              }
                            },
                          ),
                        );
                      }
                      return;
                    } catch (e) {
                      // Pay Per Ride plan not found
                    }
                  }

                  // Normal ride start if not Pay Per Ride
                  final ride = await detailVm.startRide(bike);
                  if (ride != null && context.mounted) {
                    mapVm.onRideStarted(ride);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BikePanelList extends StatelessWidget {
  final List<Bike> bikes;
  final bool isStartingRide;
  final Future<void> Function(Bike) onBikeTap;

  const _BikePanelList({
    required this.bikes,
    required this.isStartingRide,
    required this.onBikeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bikes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No available bikes at this station.'),
      );
    }

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: bikes
              .map(
                (bike) => GestureDetector(
                  onTap: isStartingRide ? null : () => onBikeTap(bike),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _BikePanelRow(bike: bike),
                  ),
                ),
              )
              .toList(),
        ),
        if (isStartingRide)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white54,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _BikePanelRow extends StatelessWidget {
  final Bike bike;

  const _BikePanelRow({required this.bike});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/bike_in_view_bike_in_a_station_detail.png',
          width: 60,
          height: 44,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_bike, size: 40, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BikeId: ${bike.bikeNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Slot: #${bike.slotNumber}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ],
    );
  }
}
