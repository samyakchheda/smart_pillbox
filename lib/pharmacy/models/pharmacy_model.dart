class Pharmacy {
  final String name;
  final double lat;
  final double lon;
  final String phoneNumber;

  Pharmacy({required this.name, required this.lat, required this.lon, required this.phoneNumber});

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      name: json['name'] as String,
      lat: json['geometry']['location']['lat'] as double,
      lon: json['geometry']['location']['lng'] as double,
      phoneNumber: json['formatted_phone_number'] as String? ?? '',
    );
  }
}

