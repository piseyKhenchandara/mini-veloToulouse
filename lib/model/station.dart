class Station {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int availableBikes;
  final int totalDocks;
  final int availableDocks;

  const Station({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.availableBikes,
    required this.totalDocks,
    required this.availableDocks,
  });
}

