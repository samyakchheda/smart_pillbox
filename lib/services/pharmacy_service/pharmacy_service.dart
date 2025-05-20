import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:home/models/pharmacy_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// 740392cb4amsh77a7f25bdf77fb6p1c7346jsnf94b51aee5af

class PharmacyService {
  static const String _baseUrl = 'https://google-map-places.p.rapidapi.com';
  static const String _apiKey =
      '482e99f096mshef50116a37ccc61p12b962jsnc32558402289';

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
      List<Pharmacy> pharmacies = [];
      for (var json in results) {
        // Create a Pharmacy object from the nearby search JSON.
        // Note: Nearby search may not include a phone number.
        Pharmacy pharmacy = Pharmacy.fromJson(json);
        // Try to fetch place details to update the phone number.
        final placeId = json['place_id'];
        if (placeId != null) {
          try {
            final details = await fetchPlaceDetails(placeId);
            // details[2] contains the phone number.
            pharmacy.phoneNumber = details[2] as String;
          } catch (e) {
            // If there's an error, leave phoneNumber as is.
          }
        }
        pharmacies.add(pharmacy);
      }
      return pharmacies;
    } else {
      throw Exception('Failed to load pharmacies');
    }
  }

  static Future<List<dynamic>> fetchPlaceDetails(String placeId) async {
    const String detailsUrl =
        'https://google-map-places.p.rapidapi.com/maps/api/place/details/json';
    final Uri uri = Uri.parse('$detailsUrl?place_id=$placeId&language=en');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key':
              "482e99f096mshef50116a37ccc61p12b962jsnc32558402289",
          'x-rapidapi-host': 'google-map-places.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final placedetails = jsonDecode(response.body)['result'];

        // Parse geometry to get the location.
        final selectedLocation = GeoPoint(
          latitude: placedetails['geometry']['location']['lat'],
          longitude: placedetails['geometry']['location']['lng'],
        );

        // Parse the phone number if available.
        final phoneNumber = placedetails['formatted_phone_number'] ?? '';

        // Return location, the full details, and phoneNumber.
        return [selectedLocation, placedetails, phoneNumber];
      } else {
        throw Exception('Failed to fetch place details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching place details: $e');
    }
  }
}
