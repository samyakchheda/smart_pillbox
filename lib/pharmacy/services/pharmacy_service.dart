import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/pharmacy_model.dart';

class PharmacyService {
  static const String _baseUrl = 'https://google-map-places.p.rapidapi.com';
  static const String _apiKey =
      '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121';

  Future<List<Pharmacy>> getNearbyPharmacies(Position position) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=1000&type=pharmacy&language=en&opennow=true&rankby=prominence'),
      headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': 'google-map-places.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map((json) => Pharmacy.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pharmacies');
    }
  }
}
