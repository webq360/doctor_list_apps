import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class MyAmbulanceRequestsScreen extends StatefulWidget {
  const MyAmbulanceRequestsScreen({super.key});

  @override
  State<MyAmbulanceRequestsScreen> createState() => _MyAmbulanceRequestsScreenState();
}

class _MyAmbulanceRequestsScreenState extends State<MyAmbulanceRequestsScreen> {
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.dio.get('/ambulance-requests/my');
      if (mounted) setState(() { _requests = res.data as List; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Requests', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.airport_shuttle_outlined, size: 64, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 12),
                      Text('No requests yet', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) => _RequestCard(
                      request: _requests[i],
                      onRefresh: _fetch,
                    ),
                  ),
                ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onRefresh;
  const _RequestCard({required this.request, required this.onRefresh});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  List<dynamic> _bids = [];
  bool _loadingBids = false;
  bool _expanded = false;

  static const _statusColor = {
    'pending': Color(0xFFFF9500),
    'bidding': Color(0xFF2B3EE6),
    'accepted': Color(0xFF4CAF50),
    'completed': Color(0xFF34C759),
    'cancelled': Color(0xFFFF3B30),
  };

  Future<void> _loadBids() async {
    setState(() { _loadingBids = true; _expanded = true; });
    try {
      final res = await ApiClient.dio.get('/ambulance-requests/${widget.request['_id']}/bids');
      if (mounted) setState(() { _bids = res.data as List; _loadingBids = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingBids = false);
    }
  }

  Future<void> _acceptBid(String bidId) async {
    try {
      await ApiClient.dio.post('/ambulance-requests/${widget.request['_id']}/bids/$bidId/accept');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid accepted! Ambulance is on the way.'), backgroundColor: Color(0xFF4CAF50)),
        );
        widget.onRefresh();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept bid'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final status = req['status'] as String? ?? 'pending';
    final address = req['pickupLocation']?['address'] ?? '';
    final tripType = req['tripType'] ?? 'instant';
    final scheduledTime = req['scheduledTime'];
    final statusColor = _statusColor[status] ?? const Color(0xFF888888);
    final acceptedBid = req['acceptedBidId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tripType == 'instant' ? const Color(0xFFFFEEE8) : const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tripType == 'instant' ? Icons.flash_on_rounded : Icons.calendar_today_rounded,
                            size: 12,
                            color: tripType == 'instant' ? const Color(0xFFFF6B35) : const Color(0xFF2B3EE6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tripType == 'instant' ? 'Instant' : 'Scheduled',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tripType == 'instant' ? const Color(0xFFFF6B35) : const Color(0xFF2B3EE6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(address, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)))),
                  ],
                ),
                if (req['destination']?['address'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.flag_rounded, size: 16, color: Color(0xFFFF3B30)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(req['destination']['address'] as String,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)))),
                    ],
                  ),
                ],
                if (scheduledTime != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF888888)),
                      const SizedBox(width: 6),
                      Text(_formatTime(scheduledTime), style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    ],
                  ),
                ],

                // Accepted bid info
                if (acceptedBid != null && acceptedBid is Map) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ Ambulance Booked', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                        const SizedBox(height: 6),
                        Text('Driver: ${acceptedBid['ambulanceUserId']?['name'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E))),
                        Text('Phone: ${acceptedBid['ambulanceUserId']?['phone'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2B3EE6))),
                        Text('Fare: ৳${acceptedBid['fare']}  •  ETA: ${acceptedBid['estimatedTime']} min',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bids section — only show for pending/bidding
          if (status == 'pending' || status == 'bidding') ...[
            const Divider(height: 1),
            InkWell(
              onTap: _expanded ? () => setState(() => _expanded = false) : _loadBids,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 16, color: Color(0xFF2B3EE6)),
                    const SizedBox(width: 8),
                    Text(
                      status == 'bidding' ? 'View Bids' : 'No bids yet',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2B3EE6)),
                    ),
                    const Spacer(),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF2B3EE6), size: 18),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              _loadingBids
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _bids.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No bids yet. Waiting for drivers...', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
                        )
                      : Column(
                          children: _bids.map((bid) => _BidTile(bid: bid, onAccept: () => _acceptBid(bid['_id']))).toList(),
                        ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _BidTile extends StatelessWidget {
  final Map<String, dynamic> bid;
  final VoidCallback onAccept;
  const _BidTile({required this.bid, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final driver = bid['ambulanceUserId'];
    final hospital = bid['hospitalId'];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFFFEEE8), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person, color: Color(0xFFFF6B35), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver?['name'] ?? 'Driver', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    if (hospital != null)
                      Text(hospital['name'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('৳${bid['fare']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                  Text('${bid['estimatedTime']} min', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.route_outlined, size: 13, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Text('${bid['estimatedDistance']} km', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
