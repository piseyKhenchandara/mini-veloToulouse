import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/bike_repository.dart';
import '../../../model/bike.dart';
import '../../../model/station.dart';

class StationDetailViewModel extends ChangeNotifier {
  final Station _station;
  final BikeRepository _bikeRepository;

  StationDetailViewModel(this._station, this._bikeRepository) {
    _load();
  }

  Station get station => _station;

  List<Bike> _bikes = [];
  bool _isLoading = true;
  String? _error;
  String? _distanceText;

  List<Bike> get bikes => _bikes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get distanceText => _distanceText;
  int get availableCount => _bikes.length;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([_fetchBikes(), _fetchDistance()]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
