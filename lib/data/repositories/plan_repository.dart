import 'package:mini_velo/data/dto/plan_dto.dart';
import 'package:mini_velo/model/plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanRepository {
  final _client = Supabase.instance.client;

  Future<List<Plan>> fetchAllPlans() async {
    final data = await _client.from('subscription_plans').select();
    return (data as List<dynamic>)
        .map((e) => PlanDto.fromJson(e).toPlan())
        .toList();
  }

  Future<Plan?> fetchUserActivePlan(String userId) async {
    final data = await _client
        .from('user_subscriptions')
        .select('*, subscription_plans(*)')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (data == null) return null;
    return PlanDto.fromJson(data['subscription_plans']).toPlan();
  }

  Future<DateTime?> fetchPlanExpiresAt(String userId) async {
    final data = await _client
        .from('user_subscriptions')
        .select('end_date')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    if (data == null || data['end_date'] == null) return null;
    return DateTime.parse(data['end_date']);
  }

  Future<void> buyPlan({required String userId, required Plan plan}) async {
    // deactivate any existing plan
    await _client
        .from('user_subscriptions')
        .update({'is_active': false})
        .eq('user_id', userId);

    final now = DateTime.now().toUtc();
    final expiresAt = plan.time == 0
        ? null // perRide has no expiry
        : now.add(Duration(hours: plan.time * 24));

    await _client.from('user_subscriptions').insert({
      'user_id': userId,
      'plan_id': plan.id,
      'is_active': true,
      'start_date': now.toIso8601String(),
      'end_date': expiresAt?.toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> fetchUserRideStats(String userId) async {
    final data = await _client
        .from('rides')
        .select('duration_seconds')
        .eq('user_id', userId)
        .eq('status', 'completed');

    if ((data as List).isEmpty) {
      return {'total_rides': 0, 'total_duration_seconds': 0};
    }

    int totalDurationSeconds = 0;
    for (var ride in data) {
      final duration = ride['duration_seconds'] as int?;
      if (duration != null) {
        totalDurationSeconds += duration;
      }
    }

    return {
      'total_rides': data.length,
      'total_duration_seconds': totalDurationSeconds,
    };
  }
}
