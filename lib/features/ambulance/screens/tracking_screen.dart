import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/api/api_client.dart';

class TrackingScreen extends StatefulWidget {
  final String requestId;

  const TrackingScreen({super.key, required this.requestId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  LatLng _driverLocation = const LatLng(23.8103, 90.4125); // Default Dhaka
  LatLng _userLocation = const LatLng(23.8103, 90.4125);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _status = 'On the Way';
  double _distance = 0;
  int _eta = 0;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
    // Simulate realtime updates
    // In real app, use socket or polling
  }

  Future<void> _fetchTrackingData() async {
    try {
      final res = await ApiClient.dio.get('/tracking/${widget.requestId}');
      final data = res.data;
      final driverLat = (data['driverLat'] as num?)?.toDouble() ?? 23.8103;
      final driverLng = (data['driverLng'] as num?)?.toDouble() ?? 90.4125;
      final userLat = (data['userLat'] as num?)?.toDouble() ?? 23.8103;
      final userLng = (data['userLng'] as num?)?.toDouble() ?? 90.4125;
      setState(() {
        _driverLocation = LatLng(driverLat, driverLng);
        _userLocation = LatLng(userLat, userLng);
        _status = data['status'] ?? 'On the Way';
        _distance = (data['distance'] as num?)?.toDouble() ?? 0;
        _eta = (data['eta'] as num?)?.toInt() ?? 0;
        _updateMarkers();
        _updatePolylines();
      });
    } catch (_) {
      // Handle error
    }
  }

  void _updateMarkers() {
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: _driverLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'Ambulance'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('user'),
      position: _userLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Pickup'),
    ));
  }

  void _updatePolylines() {
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [_driverLocation, _userLocation],
      color: Colors.blue,
      width: 5,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _driverLocation, zoom: 15),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text('Status: $_status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Distance: ${_distance.toStringAsFixed(1)} km'),
                Text('ETA: $_eta min'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}