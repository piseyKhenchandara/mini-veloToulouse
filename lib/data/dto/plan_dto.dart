import 'package:mini_velo/model/plan.dart';

class PlanDto {
  final String id;
  final String planName;
  final double price;
  final int time;

  const PlanDto({required this.id, required this.planName, required this.price, required this.time});

  factory PlanDto.fromJson(Map<String, dynamic> json) => PlanDto(
    id: json['id'] as String,
    planName: json['name'] as String,
    price: (json['price'] as double?) ?? 0.0,
    time: json['duration_days'] as int,
  );

  Plan toPlan() => Plan(
    id: id,
    planName: planName,
    price: price,
    time: time,
  );
}