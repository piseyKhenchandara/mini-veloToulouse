import '../../model/station.dart';

class StationDto {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int availableBikes;
  final int totalDocks;

  const StationDto({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.availableBikes,
    required this.totalDocks,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) => StationDto(
        id: json['id'] as String,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        availableBikes: json['available_bikes'] as int,
        totalDocks: json['total_docks'] as int,
      );

  Station toStation() => Station(
        id: id,
        name: name,
        lat: lat,
        lng: lng,
        availableBikes: availableBikes,
        totalDocks: totalDocks,
      );
}
