import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationService {
  static Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Uri url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=18'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Sahyog Civic Reporting App',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final Map<String, dynamic>? address =
          data['address'];

      if (address == null) {
        return null;
      }

      final List<String> parts = [];

      if (address['neighbourhood'] != null) {
        parts.add(address['neighbourhood'].toString());
      } else if (address['suburb'] != null) {
        parts.add(address['suburb'].toString());
      }

      if (address['city'] != null) {
        parts.add(address['city'].toString());
      } else if (address['town'] != null) {
        parts.add(address['town'].toString());
      } else if (address['village'] != null) {
        parts.add(address['village'].toString());
      }

      if (address['state'] != null) {
        parts.add(address['state'].toString());
      }

      if (parts.isNotEmpty) {
        return parts.join(', ');
      }

      return data['display_name']?.toString();
    } catch (_) {
      return null;
    }
  }
}