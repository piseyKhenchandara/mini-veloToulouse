import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/bike_repository.dart';
import '../../../model/bike.dart';
import '../../../model/station.dart';
import '../../../ui/theme/app_colors.dart';
import 'station_detail_view_model.dart';

class StationDetailScreen extends StatelessWidget {
  final Station station;

  const StationDetailScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StationDetailViewModel(station, BikeRepository()),
      child: const _StationDetailView(),
    );
  }
}

class _StationDetailView extends StatelessWidget {
  const _StationDetailView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StationDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vm.station.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text('Error: ${vm.error}'))
              : _StationDetailBody(vm: vm),
    );
  }
}

class _StationDetailBody extends StatelessWidget {
  final StationDetailViewModel vm;

  const _StationDetailBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoRow(vm: vm),
        _AvailabilityBox(vm: vm),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Available Bikes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _BikeList(bikes: vm.bikes)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final StationDetailViewModel vm;

  const _InfoRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Icon(Icons.dock, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'Total: ${vm.station.totalDocks} Bikes',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Spacer(),
          if (vm.distanceText != null) ...[
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${vm.distanceText} away',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityBox extends StatelessWidget {
  final StationDetailViewModel vm;

  const _AvailabilityBox({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${vm.availableCount} / ${vm.station.totalDocks} Available Bikes',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BikeList extends StatelessWidget {
  final List<Bike> bikes;

  const _BikeList({required this.bikes});

  @override
  Widget build(BuildContext context) {
    if (bikes.isEmpty) {
      return const Center(child: Text('No available bikes at this station.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bikes.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (_, index) => _BikeRow(bike: bikes[index]),
    );
  }
}

class _BikeRow extends StatelessWidget {
  final Bike bike;

  const _BikeRow({required this.bike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/images/bike_in_view_bike_in_a_station_detail.png',
            width: 64,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BikeId: ${bike.bikeNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Slot: #${bike.slotNumber}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
