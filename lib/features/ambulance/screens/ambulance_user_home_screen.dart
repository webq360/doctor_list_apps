import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';

class AmbulanceUserHomeScreen extends StatefulWidget {
  const AmbulanceUserHomeScreen({super.key});

  @override
  State<AmbulanceUserHomeScreen> createState() => _AmbulanceUserHomeScreenState();
}

class _AmbulanceUserHomeScreenState extends State<AmbulanceUserHomeScreen> {
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
      final res = await ApiClient.dio.get('/ambulance-requests');
      if (mounted) setState(() { _requests = res.data as List; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF3B30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, ${user?.name ?? 'Driver'}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text('Ambulance Driver', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Incoming Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Text('${_requests.length} active', style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFCCCCCC)),
                            SizedBox(height: 12),
                            Text('No requests right now', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15)),
                            SizedBox(height: 4),
                            Text('Pull to refresh', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _requests.length,
                          itemBuilder: (_, i) => _RequestTile(
                            request: _requests[i],
                            onBidPlaced: _fetch,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onBidPlaced;
  const _RequestTile({required this.request, required this.onBidPlaced});

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _showBidForm = false;
  final _fareCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _distCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _fareCtrl.dispose();
    _timeCtrl.dispose();
    _distCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeBid() async {
    final fare = double.tryParse(_fareCtrl.text.trim());
    final time = int.tryParse(_timeCtrl.text.trim());
    final dist = double.tryParse(_distCtrl.text.trim());
    if (fare == null || time == null || dist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiClient.dio.post('/ambulance-requests/${widget.request['_id']}/bids', data: {
        'fare': fare,
        'estimatedTime': time,
        'estimatedDistance': dist,
      });
      if (mounted) {
        setState(() { _showBidForm = false; _submitting = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid placed successfully!'), backgroundColor: Color(0xFF4CAF50)),
        );
        widget.onBidPlaced();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place bid'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final patient = req['patientId'];
    final address = req['pickupLocation']?['address'] ?? '';
    final tripType = req['tripType'] ?? 'instant';
    final scheduledTime = req['scheduledTime'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
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
                            tripType == 'instant' ? 'INSTANT' : 'SCHEDULED',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold,
                              color: tripType == 'instant' ? const Color(0xFFFF6B35) : const Color(0xFF2B3EE6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(_timeAgo(req['createdAt'] ?? ''),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 15, color: Color(0xFF888888)),
                    const SizedBox(width: 6),
                    Text(patient?['name'] ?? 'Patient', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 8),
                    Text(patient?['phone'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF2B3EE6))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFFFF3B30)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(address, style: const TextStyle(fontSize: 13, color: Color(0xFF555555)))),
                  ],
                ),
                if (scheduledTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 13, color: Color(0xFF888888)),
                      const SizedBox(width: 6),
                      Text(_formatTime(scheduledTime), style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          if (!_showBidForm)
            InkWell(
              onTap: () => setState(() => _showBidForm = true),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_rounded, size: 16, color: Color(0xFFFF6B35)),
                    SizedBox(width: 8),
                    Text('Place a Bid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF6B35))),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Bid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _BidField(ctrl: _fareCtrl, label: 'Fare (৳)', hint: '500')),
                      const SizedBox(width: 10),
                      Expanded(child: _BidField(ctrl: _timeCtrl, label: 'ETA (min)', hint: '15')),
                      const SizedBox(width: 10),
                      Expanded(child: _BidField(ctrl: _distCtrl, label: 'Distance (km)', hint: '3.5')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showBidForm = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _placeBid,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: _submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Submit Bid', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }
}

class _BidField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  const _BidField({required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
