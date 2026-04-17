import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import 'map_view_model.dart';
import 'return_station_panel_view_model.dart';

class ReturnStationPanel extends StatelessWidget {
  const ReturnStationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReturnStationPanelViewModel>();

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
          // station name + close
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
          // available docks box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${vm.emptySlots.length} / ${vm.station.totalDocks} Available Slots',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select a slot to return your bike',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          if (vm.returnError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Failed: ${vm.returnError}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          const SizedBox(height: 8),
          // slot list
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
            Flexible(child: _SlotList(vm: vm)),
        ],
      ),
    );
  }
}

class _SlotList extends StatelessWidget {
  final ReturnStationPanelViewModel vm;

  const _SlotList({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.emptySlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No available slots at this station.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.emptySlots.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final slotNumber = vm.emptySlots[index];
        return _SlotRow(
          slotNumber: slotNumber,
          isReturning: vm.isReturning,
          onTap: () async {
            final mapVm = context.read<MapViewModel>();
            final success = await context
                .read<ReturnStationPanelViewModel>()
                .returnBike(slotNumber);
            if (success && context.mounted) {
              mapVm.onRideEnded();
            }
          },
        );
      },
    );
  }
}

class _SlotRow extends StatelessWidget {
  final int slotNumber;
  final bool isReturning;
  final VoidCallback onTap;

  const _SlotRow({
    required this.slotNumber,
    required this.isReturning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(
            'assets/images/bike_in_return_bike_in_a_station.png',
            width: 60,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.local_parking, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Text(
            'Slot #$slotNumber',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: isReturning ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isReturning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Return Here', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
