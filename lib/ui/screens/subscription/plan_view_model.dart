import 'package:flutter/material.dart';
import 'package:mini_velo/data/repositories/plan_repository.dart';
import '../../../model/plan.dart';

class PlanViewModel extends ChangeNotifier {
  final PlanRepository _planRepository;

  PlanViewModel(this._planRepository);

  List<Plan> _plans = [];
  bool _isLoading = false;
  String? _error;

  Plan? _selectedPlan; // user clicked
  Plan? _activePlan; // from database

  // getters
  List<Plan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Plan? get selectedPlan => _selectedPlan;
  Plan? get activePlan => _activePlan;

  // 🔹 select from UI
  void selectPlan(Plan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  // 🔹 load all plans
  Future<void> fetchAllPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _planRepository.fetchAllPlans();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 load user's active plan
  Future<void> fetchUserPlan(String userId) async {
    try {
      _activePlan = await _planRepository.fetchUserActivePlan(userId);
      notifyListeners(); // ✅ IMPORTANT
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 🔹 initialize everything (better than constructor calls)
  Future<void> init(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _planRepository.fetchAllPlans(),
        _planRepository.fetchUserActivePlan(userId),
      ]);

      _plans = results[0] as List<Plan>;
      _activePlan = results[1] as Plan?;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
