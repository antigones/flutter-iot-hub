import 'package:latlong2/latlong.dart';

class Location {
  final int timestamp;
  final double long;
  final double lat;
  final int battery;

  Location({
    required this.timestamp,
    required this.long,
    required this.lat,
    required this.battery,
  });

  Location.fromJson(Map<String, dynamic> json)
      : timestamp = json['timestamp'] as int,
        long = json['long'] as double,
        lat = json['lat'] as double,
        battery = json['batt'] as int;

  Map<String, Object?> toMap() {
    return {
      'timestamp': timestamp,
      'long': long,
      'lat': lat,
      'battery': battery,
    };
  }

  @override
  String toString() {
    return 'Location{timestamp: $timestamp, long: $long, lat: $lat, batt: $battery}';
  }
}