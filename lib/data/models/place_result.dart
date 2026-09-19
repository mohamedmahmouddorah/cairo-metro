class PlaceResult {
  final String name;
  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? placeId;

  const PlaceResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.placeId,
  });
}
