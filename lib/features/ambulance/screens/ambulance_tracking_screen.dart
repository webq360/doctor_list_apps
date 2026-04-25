import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/api/api_client.dart';

class AmbulanceTrackingScreen extends StatefulWidget {
  final String requestId;
  const AmbulanceTrackingScreen({super.key, required this.requestId});

  @override
  State<AmbulanceTrackingScreen> createState() => _AmbulanceTrackingScreenState();
}

class _AmbulanceTrackingScreenState extends State<AmbulanceTrackingScreen> {
  Map<String, dynamic>? _request;
  List<dynamic> _bids = [];
  bool _loading = true;
  Timer? _pollTimer;
  GoogleMapController? _mapCtrl;

  static const _statusLabel = {
    'pending': 'Searching for drivers...',
    'bidding': 'Drivers are bidding!',
    'accepted': 'Driver selected ✓',
    'on_the_way': 'Driver is on the way 🚑',
    'arrived': 'Driver has arrived!',
    'trip_started': 'Trip in progress...',
    'completed': 'Trip completed ✓',
    'cancelled': 'Cancelled',
  };

  static const _statusColor = {
    'pending': Color(0xFFFF9500),
    'bidding': Color(0xFF2B3EE6),
    'accepted': Color(0xFF4CAF50),
    'on_the_way': Color(0xFFFF6B35),
    'arrived': Color(0xFF9C27B0),
    'trip_started': Color(0xFF2196F3),
    'completed': Color(0xFF34C759),
    'cancelled': Color(0xFFFF3B30),
  };

  @override
  void initState() {
    super.initState();
    _fetch();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiClient.dio.get('/ambulance-requests/${widget.requestId}/tracking');
      final bidsRes = await ApiClient.dio.get('/ambulance-requests/${widget.requestId}/bids');
      if (mounted) {
        setState(() {
          _request = Map<String, dynamic>.from(res.data as Map);
          _bids = bidsRes.data as List;
          _loading = false;
        });
        _updateMap();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateMap() {
    if (_mapCtrl == null || _request == null) return;
    final driverLoc = _request!['driverLocation'];
    if (driverLoc != null) {
      _mapCtrl!.animateCamera(CameraUpdate.newLatLng(
        LatLng((driverLoc['lat'] as num).toDouble(), (driverLoc['lng'] as num).toDouble()),
      ));
    }
  }

  Future<void> _acceptBid(String bidId) async {
    try {
      await ApiClient.dio.post('/ambulance-requests/${widget.requestId}/bids/$bidId/accept');
      _fetch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver selected! They are on the way.'), backgroundColor: Color(0xFF4CAF50)),
        );
      }
    } catch (_) {}
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    final req = _request;
    if (req == null) return markers;

    final pickup = req['pickupLocation'];
    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng((pickup['lat'] as num).toDouble(), (pickup['lng'] as num).toDouble()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup'),
      ));
    }

    final driver = req['driverLocation'];
    if (driver != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: LatLng((driver['lat'] as num).toDouble(), (driver['lng'] as num).toDouble()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: '🚑 Ambulance'),
      ));
    }
    return markers;
  }

  LatLng get _initialCamera {
    final pickup = _request?['pickupLocation'];
    if (pickup != null) {
      return LatLng((pickup['lat'] as num).toDouble(), (pickup['lng'] as num).toDouble());
    }
    return const LatLng(23.8103, 90.4125); // Dhaka default
  }

  @override
  Widget build(BuildContext context) {
    final status = _request?['status'] as String? ?? 'pending';
    final statusColor = _statusColor[status] ?? const Color(0xFF888888);
    final statusText = _statusLabel[status] ?? status;
    final acceptedBid = _request?['acceptedBidId'];
    final showBids = (status == 'pending' || status == 'bidding') && _bids.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ambulance Tracking', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
          : Column(
              children: [
                // Status bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: statusColor.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: statusColor)),
                      const Spacer(),
                      if (status == 'pending' || status == 'bidding')
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF9500))),
                    ],
                  ),
                ),

                // Map
                SizedBox(
                  height: 220,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: _initialCamera, zoom: 14),
                    markers: _markers,
                    onMapCreated: (ctrl) => _mapCtrl = ctrl,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Trip info
                        _InfoCard(request: _request!),
                        const SizedBox(height: 14),

                        // Accepted driver info
                        if (acceptedBid != null && acceptedBid is Map) ...[
                          _DriverCard(bid: Map<String, dynamic>.from(acceptedBid)),
                          const SizedBox(height: 14),
                        ],

                        // Bids list
                        if (showBids) ...[
                          Row(
                            children: [
                              const Icon(Icons.local_offer_rounded, size: 16, color: Color(0xFF2B3EE6)),
                              const SizedBox(width: 8),
                              Text('${_bids.length} Bids Received', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._bids.map((bid) => _BidCard(bid: bid, onAccept: () => _acceptBid(bid['_id']))),
                        ],

                        // Waiting state
                        if (status == 'pending' && _bids.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: const Column(
                              children: [
                                Icon(Icons.airport_shuttle_outlined, size: 48, color: Color(0xFFCCCCCC)),
                                SizedBox(height: 12),
                                Text('Waiting for drivers to bid...', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                                SizedBox(height: 4),
                                Text('This usually takes 1-3 minutes', style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC))),
                              ],
                            ),
                          ),

                        if (status == 'completed')
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3))),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 32),
                                SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Trip Completed!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                                  Text('Thank you for using our service.', style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                                ])),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final pickup = request['pickupLocation']?['address'] ?? '';
    final dest = request['destination']?['address'] ?? '';
    final tripType = request['tripType'] ?? 'instant';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Expanded(child: Text(pickup, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.flag_rounded, size: 16, color: Color(0xFFFF3B30)),
            const SizedBox(width: 8),
            Expanded(child: Text(dest, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(tripType == 'instant' ? Icons.flash_on_rounded : Icons.calendar_today_rounded,
                size: 14, color: tripType == 'instant' ? const Color(0xFFFF6B35) : const Color(0xFF2B3EE6)),
            const SizedBox(width: 6),
            Text(tripType == 'instant' ? 'Instant Booking' : 'Scheduled Booking',
                style: TextStyle(fontSize: 12, color: tripType == 'instant' ? const Color(0xFFFF6B35) : const Color(0xFF2B3EE6), fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  const _DriverCard({required this.bid});

  @override
  Widget build(BuildContext context) {
    final driver = bid['ambulanceUserId'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.airport_shuttle_rounded, color: Color(0xFF4CAF50), size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(driver?['name'] ?? 'Driver', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            Text(driver?['phone'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF2B3EE6))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('৳${bid['fare']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
            Text('${bid['estimatedTime']} min', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          ]),
        ],
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final VoidCallback onAccept;
  const _BidCard({required this.bid, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final driver = bid['ambulanceUserId'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFEEE8), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person, color: Color(0xFFFF6B35), size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(driver?['name'] ?? 'Driver', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            Row(children: [
              const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF888888)),
              const SizedBox(width: 3),
              Text('${bid['estimatedTime']} min', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              const SizedBox(width: 10),
              const Icon(Icons.route_outlined, size: 12, color: Color(0xFF888888)),
              const SizedBox(width: 3),
              Text('${bid['estimatedDistance']} km', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('৳${bid['fare']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
            const SizedBox(height: 6),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Select', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
