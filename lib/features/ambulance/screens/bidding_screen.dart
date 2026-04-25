import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';
import 'tracking_screen.dart';

class BiddingScreen extends StatefulWidget {
  final String requestId;

  const BiddingScreen({super.key, required this.requestId});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  List<BidModel> _bids = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBids();
  }

  Future<void> _fetchBids() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.dio.get('/bids/${widget.requestId}');
      final list = (res.data as List).map((b) => BidModel.fromJson(b as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _bids = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptBid(String bidId) async {
    try {
      await ApiClient.dio.post('/accept-bid', data: {'bidId': bidId});
      if (!mounted) return;
      // Navigate to tracking
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrackingScreen(requestId: widget.requestId)));
    } catch (_) {
      setState(() => _error = 'Failed to accept bid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ambulance'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bids.isEmpty
              ? const Center(child: Text('No bids yet'))
              : ListView.builder(
                  itemCount: _bids.length,
                  itemBuilder: (ctx, i) {
                    final bid = _bids[i];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Price: ৳${bid.price}'),
                        subtitle: Text('ETA: ${bid.eta} min'),
                        trailing: ElevatedButton(
                          onPressed: () => _acceptBid(bid.id),
                          child: const Text('Select'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}