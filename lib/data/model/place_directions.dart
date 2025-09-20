import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:touchhealth/data/model/config.dart';

class PlaceDirectionsModel {
  late LatLngBounds bounds;
  late List<PointLatLng> polylinePoints;
  late String totalDistance;
  late String totalDuration;

  PlaceDirectionsModel({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  //factory PlaceDirectionsModel.fromJson(Map<String, dynamic> json) {
  static Future<PlaceDirectionsModel> fromJsonAsync(Map<String, dynamic> json) async {
    final data = json['routes'][0] as Map<String, dynamic>;

    final northeast = data['bounds']['northeast'] as Map<String, dynamic>;
    final southwest = data['bounds']['southwest'] as Map<String, dynamic>;

    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    late String distance;
    late String duration;

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0] as Map<String, dynamic>;
      distance = leg['distance']['text'] as String;
      duration = leg['duration']['text'] as String;
    }

    // Create PolylinePoints with API key
    final polylineDecoder = PolylinePoints.enhanced(googleMapsApiKey);

    // Decode polyline using getRouteBetweenCoordinates
    final result = await polylineDecoder.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(data['legs'][0]['start_location']['lat'], data['legs'][0]['start_location']['lng']),
        destination: PointLatLng(data['legs'][0]['end_location']['lat'], data['legs'][0]['end_location']['lng']),
        mode: TravelMode.driving,
      ),
    );

    return PlaceDirectionsModel(
      bounds: bounds,
      polylinePoints: result.points,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
