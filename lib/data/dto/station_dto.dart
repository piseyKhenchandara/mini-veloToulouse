import '../../model/station.dart';

class StationDto {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int availableBikes;
  final int totalDocks;
  final int availableDocks;

  const StationDto({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.availableBikes,
    required this.totalDocks,
    required this.availableDocks,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) => StationDto(
        id: json['id'] as String,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        availableBikes: (json['available_bikes'] as num).toInt(),
        totalDocks: (json['total_docks'] as num).toInt(),
        availableDocks: (json['available_docks'] as num).toInt(),
      );

  Station toStation() => Station(
        id: id,
        name: name,
        lat: lat,
        lng: lng,
        availableBikes: availableBikes,
        totalDocks: totalDocks,
        availableDocks: availableDocks,
      );
}
