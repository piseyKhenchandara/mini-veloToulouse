import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/bike_repository.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../model/active_ride.dart';
import '../../../model/bike.dart';
import '../../../model/station.dart';

class StationDetailViewModel extends ChangeNotifier {
  final Station _station;
  final BikeRepository _bikeRepository;
  final RideRepository _rideRepository;

  StationDetailViewModel(this._station, this._bikeRepository, this._rideRepository) {
    _load();
  }

  Station get station => _station;

  List<Bike> _bikes = [];
  bool _isLoading = true;
  String? _error;
  String? _distanceText;
  bool _isStartingRide = false;
  String? _rideError;

  List<Bike> get bikes => _bikes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get distanceText => _distanceText;
  int get availableCount => _bikes.length;
  bool get isStartingRide => _isStartingRide;
  String? get rideError => _rideError;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchBikes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Load distance in background — bikes are already shown
    _fetchDistance().then((_) => notifyListeners());
  }

  Future<void> _fetchBikes() async {
    _bikes = await _bikeRepository.fetchAvailableByStation(_station.id);
  }

  Future<void> _fetchDistance() async {
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
      final meters = const Distance().as(
        LengthUnit.Meter,
        LatLng(position.latitude, position.longitude),
        LatLng(_station.lat, _station.lng),
      );

      _distanceText =
          meters < 1000 ? '${meters.round()}m' : '${(meters / 1000).toStringAsFixed(1)}km';
    } catch (_) {
      // silently ignore — distance stays null
    }
  }

  Future<ActiveRide?> startRide(Bike bike) async {
    _isStartingRide = true;
    _rideError = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.startRide(
        bikeId: bike.id,
        bikeNumber: bike.bikeNumber,
        stationId: _station.id,
        slotNumber: bike.slotNumber,
      );
      return ride;
    } catch (e) {
      _rideError = e.toString();
      return null;
    } finally {
      _isStartingRide = false;
      notifyListeners();
    }
  }
}
