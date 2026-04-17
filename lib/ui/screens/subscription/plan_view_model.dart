import 'package:flutter/material.dart';
import 'package:mini_velo/data/repositories/plan_repository.dart';
import '../../../model/plan.dart';

class PlanViewModel extends ChangeNotifier {
  final PlanRepository _planRepository;
  PlanViewModel(this._planRepository);

  List<Plan> _plans = [];
  bool _isLoading = false;
  String? _error;
  Plan? _selectedPlan;
  Plan? _activePlan;
  DateTime? _expiresAt;
  int _totalRides = 0;
  int _totalDurationSeconds = 0;
  bool _isDisposed = false;

  List<Plan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Plan? get selectedPlan => _selectedPlan;
  Plan? get activePlan => _activePlan;
  DateTime? get expiresAt => _expiresAt;
  int get totalRides => _totalRides;
  int get totalDurationSeconds => _totalDurationSeconds;

  String get totalDurationText {
    final hours = _totalDurationSeconds ~/ 3600;
    final minutes = (_totalDurationSeconds % 3600) ~/ 60;
    final seconds = _totalDurationSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  void selectPlan(Plan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  Future<void> fetchAllPlans() async {
    _isLoading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();
    try {
      _plans = await _planRepository.fetchAllPlans();
    } catch (e) {
      if (!_isDisposed) {
        _error = e.toString();
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchUserPlan(String userId) async {
    try {
      _activePlan = await _planRepository.fetchUserActivePlan(userId);
      if (!_isDisposed) {
        _expiresAt = await _planRepository.fetchPlanExpiresAt(userId);
      }
      if (!_isDisposed) {
        final stats = await _planRepository.fetchUserRideStats(userId);
        _totalRides = stats['total_rides'] as int? ?? 0;
        _totalDurationSeconds = stats['total_duration_seconds'] as int? ?? 0;
      }
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> init(String userId) async {
    _isLoading = true;
    if (!_isDisposed) notifyListeners();
    try {
      _plans = await _planRepository.fetchAllPlans();
      if (!_isDisposed) {
        _activePlan = await _planRepository.fetchUserActivePlan(userId);
      }
      if (!_isDisposed) {
        _expiresAt = await _planRepository.fetchPlanExpiresAt(userId);
      }
      if (!_isDisposed) {
        final stats = await _planRepository.fetchUserRideStats(userId);
        _totalRides = stats['total_rides'] as int? ?? 0;
        _totalDurationSeconds = stats['total_duration_seconds'] as int? ?? 0;
      }
    } catch (e) {
      if (!_isDisposed) {
        _error = e.toString();
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> buyPlan(String userId, Plan plan) async {
    try {
      await _planRepository.buyPlan(userId: userId, plan: plan);
      // refresh active plan after purchase
      if (!_isDisposed) {
        _activePlan = await _planRepository.fetchUserActivePlan(userId);
      }
      if (!_isDisposed) {
        _expiresAt = await _planRepository.fetchPlanExpiresAt(userId);
      }
      if (!_isDisposed) {
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        _error = e.toString();
        notifyListeners();
      }
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
