import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../config/map_config.dart';
import '../../../data/repositories/bike_repository.dart';
import '../../../data/repositories/plan_repository.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../data/repositories/station_repository.dart';
import '../station_detail/station_detail_view_model.dart';
import '../subscription/plan_view_model.dart';
import 'map_view_model.dart';
import 'return_station_panel.dart';
import 'return_station_panel_view_model.dart';
import 'widgets/ride_bar.dart';
import '../station_detail/station_detail_panel.dart';
import 'widgets/search_section.dart';
import 'widgets/station_bubble.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapViewModel(StationRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PlanViewModel(PlanRepository()),
        ),
      ],
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}
class _MapViewState extends State<_MapView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode(); // hiide the keyboard when a suggestion is tapped 

  @override
  void initState() {
    super.initState();
    // Initialize the plan view model with user data
    Future.microtask(() {
      final userId = "9e2536f0-d025-420c-9112-ec279dc6b146";
      final planVm = context.read<PlanViewModel>();
      planVm.init(userId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSuggestionTap(MapViewModel vm, station) {
    vm.selectStation(station);
    vm.clearSearch();
    _searchController.clear();
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (vm.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${vm.error}')));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(MapConfig.defaultLat, MapConfig.defaultLng),
              initialZoom: MapConfig.defaultZoom,
              onTap: (tapPosition, point) {
                context.read<MapViewModel>().deselectStation();
                context.read<MapViewModel>().clearSearch();
                _searchController.clear();
                _searchFocus.unfocus();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mini_velo',
              ),
              if (vm.userLocation != null && vm.selectedStation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        vm.userLocation!,
                        LatLng(vm.selectedStation!.lat, vm.selectedStation!.lng),
                      ],
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: vm.stations.map((s) => Marker(
                  point: LatLng(s.lat, s.lng),
                  width: 72,
                  height: 52,
                  child: GestureDetector(
                    onTap: () {
                      context.read<MapViewModel>().selectStation(s);
                      context.read<MapViewModel>().clearSearch();
                      _searchController.clear();
                      _searchFocus.unfocus();
                    },
                    child: StationBubble(
                      count: vm.isRiding ? s.availableDocks : s.availableBikes,
                    ),
                  ),
                )).toList(),
              ),
              if (vm.userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: vm.userLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Top overlay — ride bar + search bar + suggestions
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 50,),
                if (vm.isRiding)
                  RideBar(ride: vm.activeRide!, duration: vm.rideDuration),
                SearchSection(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onSuggestionTap: (s) => _onSuggestionTap(context.read<MapViewModel>(), s),
                ),
              ],
            ),
          ),
          // Bottom panel — station detail OR return station
          if (vm.showDetailPanel && vm.selectedStation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: vm.isRiding
                  ? ChangeNotifierProvider(
                      key: ValueKey('return_${vm.selectedStation!.id}'),
                      create: (_) => ReturnStationPanelViewModel(
                        vm.selectedStation!,
                        vm.activeRide!,
                        vm.rideDuration,
                        BikeRepository(),
                        RideRepository(),
                      ),
                      child: const ReturnStationPanel(),
                    )
                  : ChangeNotifierProvider(
                      key: ValueKey(vm.selectedStation!.id),
                      create: (_) => StationDetailViewModel(
                        vm.selectedStation!,
                        BikeRepository(),
                        RideRepository(),
                        "9e2536f0-d025-420c-9112-ec279dc6b146",
                      ),
                      child: const StationDetailPanel(),
                    ),
            ),
        ],
      ),
    );
  }
}
