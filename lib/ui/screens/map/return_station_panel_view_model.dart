import 'package:flutter/material.dart';

import '../../../data/repositories/bike_repository.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../model/active_ride.dart';
import '../../../model/station.dart';

class ReturnStationPanelViewModel extends ChangeNotifier {
  final Station _station;
  final ActiveRide _activeRide;
  final BikeRepository _bikeRepository;
  final RideRepository _rideRepository;
  final Duration _rideDuration;

  ReturnStationPanelViewModel(
    this._station,
    this._activeRide,
    this._rideDuration,
    this._bikeRepository,
    this._rideRepository,
  ) {
    _load();
  }

  Station get station => _station;

  List<int> _emptySlots = [];
  bool _isLoading = true;
  String? _error;
  bool _isReturning = false;
  String? _returnError;

  List<int> get emptySlots => _emptySlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isReturning => _isReturning;
  String? get returnError => _returnError;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _emptySlots = await _bikeRepository.fetchEmptySlots(
        _station.id,
        _station.totalDocks,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> returnBike(int slotNumber) async {
    _isReturning = true;
    _returnError = null;
    notifyListeners();

    try {
      await _rideRepository.endRide(
        rideId: _activeRide.id,
        bikeId: _activeRide.bikeId,
        endStationId: _station.id,
        endSlotNumber: slotNumber,
        durationSeconds: _rideDuration.inSeconds,
      );
      return true;
    } catch (e) {
      _returnError = e.toString();
      return false;
    } finally {
      _isReturning = false;
      notifyListeners();
    }
  }
}
