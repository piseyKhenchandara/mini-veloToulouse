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
          .select('*, subscription_plans(*)') // join plan table
          .eq('user_id', userId)
          .eq('is_active', 'TRUE')
          .maybeSingle();

      if (data == null) return null;

      final planJson = data['subscription_plans'];

      return PlanDto.fromJson(planJson).toPlan();
    }

  }
