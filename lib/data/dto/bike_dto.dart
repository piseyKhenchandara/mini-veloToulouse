import '../../model/bike.dart';

class BikeDto {
  final String id;
  final String bikeNumber;
  final int slotNumber;
  final String status;

  const BikeDto({
    required this.id,
    required this.bikeNumber,
    required this.slotNumber,
    required this.status,
  });

  factory BikeDto.fromJson(Map<String, dynamic> json) => BikeDto(
        id: json['id'] as String,
        bikeNumber: json['bike_number'] as String,
        slotNumber: (json['slot_number'] as int?) ?? 0,
        status: json['status'] as String,
      );

  Bike toBike() => Bike(
        id: id,
        bikeNumber: bikeNumber,
        slotNumber: slotNumber,
        status: status,
      );
}
