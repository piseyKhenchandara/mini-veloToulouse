import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/station_repository.dart';
import '../../../model/active_ride.dart';
import '../../../model/station.dart';

class MapViewModel extends ChangeNotifier {
  final StationRepository _repository;

  MapViewModel(this._repository) {
    fetchStations();
    _fetchUserLocation();
  }

  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;
  Station? _selectedStation;
  LatLng? _userLocation;
  bool _showDetailPanel = false;
  ActiveRide? _activeRide;
  Duration _rideDuration = Duration.zero;
  Timer? _rideTimer;
  String _searchQuery = '';

  List<Station> get stations => _stations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Station? get selectedStation => _selectedStation;
  LatLng? get userLocation => _userLocation;
  bool get showDetailPanel => _showDetailPanel;
  ActiveRide? get activeRide => _activeRide;
  bool get isRiding => _activeRide != null;
  Duration get rideDuration => _rideDuration;

  List<Station> get searchSuggestions {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _stations
        .where((s) => s.name.toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) _showDetailPanel = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void onRideStarted(ActiveRide ride) {
    _activeRide = ride;
    _showDetailPanel = false;
    _selectedStation = null;
    _searchQuery = '';
    _rideDuration = Duration.zero;
    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _rideDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
    fetchStations();
  }

  void onRideEnded() {
    _rideTimer?.cancel();
    _activeRide = null;
    _rideDuration = Duration.zero;
    _selectedStation = null;
    _showDetailPanel = false;
    _searchQuery = '';
    notifyListeners();
    fetchStations();
  }

  void selectStation(Station station) {
    _selectedStation = station;
    _showDetailPanel = true;
    notifyListeners();
  }

  void closePanel() {
    _showDetailPanel = false;
    notifyListeners();
  }

  void deselectStation() {
    _selectedStation = null;
    _showDetailPanel = false;
    notifyListeners();
  }

  Future<void> _fetchUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (_) {
      // silently ignore — map still works without user location
    }
  }

  Future<void> fetchStations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stations = await _repository.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _rideTimer?.cancel();
    super.dispose();
  }
}
