import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/station.dart';
import '../dto/station_dto.dart';

class StationRepository {
  final _client = Supabase.instance.client;

  Future<List<Station>> fetchAll() async {
    final data = await _client.from('station_summary').select();
    return (data as List)
        .map((e) => StationDto.fromJson(e as Map<String, dynamic>).toStation())
        .toList();
  }
}
