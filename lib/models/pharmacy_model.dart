class Pharmacy {
  final String name;
  final double lat;
  final double lon;
  String phoneNumber; // This field will be updated from Place Details

  Pharmacy({
    required this.name,
    required this.lat,
    required this.lon,
    this.phoneNumber = '',
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      name: json['name'] as String,
      lat: (json['geometry']['location']['lat'] as num).toDouble(),
      lon: (json['geometry']['location']['lng'] as num).toDouble(),
      // Nearby search may not have a phone number so default to empty.
      phoneNumber: '',
    );
  }
}
