class ActiveRide {
  final String id;
  final String bikeId;
  final String bikeNumber;
  final String startStationId;
  final int startSlotNumber;
  final DateTime startTime;

  const ActiveRide({
    required this.id,
    required this.bikeId,
    required this.bikeNumber,
    required this.startStationId,
    required this.startSlotNumber,
    required this.startTime,
  });

  factory ActiveRide.fromJson(Map<String, dynamic> json) => ActiveRide(
        id: json['id'] as String,
        bikeId: json['bike_id'] as String,
        bikeNumber: json['bike_number'] as String,
        startStationId: json['start_station_id'] as String,
        startSlotNumber: (json['start_slot_number'] as int?) ?? 0,
        startTime: DateTime.parse(json['start_time'] as String),
      );
}
