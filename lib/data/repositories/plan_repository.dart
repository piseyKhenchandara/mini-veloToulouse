import 'package:mini_velo/data/dto/plan_dto.dart';
import 'package:mini_velo/model/plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanRepository {
  final _client = Supabase.instance.client;

  Future<List<Plan>> fetchAllPlan(String planId) async {
    final data = await _client
        .from('subscription_plan')
        .select()
        .eq('id', planId);

    return (data as List)
        .map((e) => PlanDto.fromJson(e as Map<String, dynamic>).toPlan())
        .toList();
  }
}
