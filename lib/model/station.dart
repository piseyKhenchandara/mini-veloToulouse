class Station {
  final String id;
  final String name;
  final double lat; // y axis
  final double lng; // x axis
  final int availableBikes;
  final int totalDocks;

  const Station({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.availableBikes,
    required this.totalDocks,
  });

  int get emptyDocks => totalDocks - availableBikes;
}
