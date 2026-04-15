import 'package:flutter/material.dart';

import '../../../data/repositories/station_repository.dart';
import '../../../model/station.dart';

class MapViewModel extends ChangeNotifier {
  final StationRepository _repository;

  MapViewModel(this._repository) {
    fetchStations();
  }

  List<Station> _stations = [];
  bool _isLoading = true;
  String? _error;

  List<Station> get stations => _stations;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
