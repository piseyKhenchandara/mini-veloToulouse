import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/active_ride.dart';

class RideRepository {
  final _client = Supabase.instance.client;

  Future<ActiveRide> startRide({
    required String userId,
    required String bikeId,
    required String bikeNumber,
    required String stationId,
    required int slotNumber,
  }) async {
    final rideData = await _client.from('rides').insert({
      'user_id': userId,
      'bike_id': bikeId,
      'bike_number': bikeNumber,
      'start_station_id': stationId,
      'start_slot_number': slotNumber,
      'start_time': DateTime.now().toUtc().toIso8601String(),
      'status': 'active',
    }).select().single();

    await _client.from('bikes').update({
      'status': 'in_use',
      'station_id': null,
      'slot_number': null,
    }).eq('id', bikeId);

    return ActiveRide.fromJson(rideData);
  }

  Future<void> endRide({
    required String rideId,
    required String bikeId,
    required String endStationId,
    required int endSlotNumber,
    required int durationSeconds,
  }) async {
    await _client.from('rides').update({
      'end_station_id': endStationId,
      'end_slot_number': endSlotNumber,
      'end_time': DateTime.now().toUtc().toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': 'completed',
    }).eq('id', rideId);

    await _client.from('bikes').update({
      'status': 'available',
      'station_id': endStationId,
      'slot_number': endSlotNumber,
    }).eq('id', bikeId);
  }
}

