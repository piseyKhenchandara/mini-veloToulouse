import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/bike.dart';
import '../dto/bike_dto.dart';

class BikeRepository {
  final _client = Supabase.instance.client;

  Future<List<Bike>> fetchAvailableByStation(String stationId) async {
    final data = await _client
        .from('bikes')
        .select()
        .eq('station_id', stationId)
        .eq('status', 'available');
    return (data as List)
        .map((e) => BikeDto.fromJson(e as Map<String, dynamic>).toBike())
        .toList();
  }
}
