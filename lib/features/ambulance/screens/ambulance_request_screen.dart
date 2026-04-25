import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/api/api_client.dart';
import 'ambulance_tracking_screen.dart';

class AmbulanceRequestScreen extends StatefulWidget {
  const AmbulanceRequestScreen({super.key});
  @override
  State<AmbulanceRequestScreen> createState() => _AmbulanceRequestScreenState();
}

class _AmbulanceRequestScreenState extends State<AmbulanceRequestScreen> {
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  LatLng? _pickupLatLng;
  LatLng? _destLatLng;
  String _tripType = 'instant';
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _loading = false;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _pickupLatLng = LatLng(pos.latitude, pos.longitude);
        _pickupCtrl.text = 'My Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
        _locating = false;
      });
    } catch (_) {
      setState(() => _locating = false);
    }
  }

  String get _scheduledLabel {
    if (_scheduledDate == null) return 'Select Date & Time';
    final d = _scheduledDate!;
    final t = _scheduledTime;
    return '${d.day}/${d.month}/${d.year}${t != null ? '  ${t.format(context)}' : ''}';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B35))),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B35))),
        child: child!,
      ),
    );
    if (!mounted) return;
    setState(() { _scheduledDate = date; _scheduledTime = time; });
  }

  Future<void> _submit() async {
    final pickup = _pickupCtrl.text.trim();
    final dest = _destCtrl.text.trim();
    if (pickup.isEmpty) { setState(() => _error = 'Enter pickup location'); return; }
    if (dest.isEmpty) { setState(() => _error = 'Enter destination'); return; }
    if (_tripType == 'scheduled' && _scheduledDate == null) { setState(() => _error = 'Select date & time'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      String? scheduledTime;
      if (_tripType == 'scheduled' && _scheduledDate != null) {
        final t = _scheduledTime ?? TimeOfDay.now();
        scheduledTime = DateTime(_scheduledDate!.year, _scheduledDate!.month, _scheduledDate!.day, t.hour, t.minute).toIso8601String();
      }

      final res = await ApiClient.dio.post('/ambulance-requests', data: {
        'pickupLocation': {
          'lat': _pickupLatLng?.latitude ?? 0.0,
          'lng': _pickupLatLng?.longitude ?? 0.0,
          'address': pickup,
        },
        'destination': {
          'lat': _destLatLng?.latitude ?? 0.0,
          'lng': _destLatLng?.longitude ?? 0.0,
          'address': dest,
        },
        'tripType': _tripType,
        if (scheduledTime != null) 'scheduledTime': scheduledTime,
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });

      if (!mounted) return;
      final requestId = res.data['_id'] as String;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => AmbulanceTrackingScreen(requestId: requestId)));
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to send request. Try again.'; _loading = false; });
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
        title: const Text('Book Ambulance', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Location Card ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  // Pickup
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pickup', style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
                              TextField(
                                controller: _pickupCtrl,
                                decoration: InputDecoration(
                                  hintText: _locating ? 'Getting your location...' : 'Enter pickup address',
                                  hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
                                  border: InputBorder.none, isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  suffixIcon: _locating
                                      ? const SizedBox(width: 16, height: 16, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50))))
                                      : IconButton(icon: const Icon(Icons.my_location, size: 18, color: Color(0xFF4CAF50)), onPressed: _getCurrentLocation),
                                ),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(indent: 38, height: 1),

                  // Destination
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF3B30), width: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Destination', style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
                              TextField(
                                controller: _destCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Where are you going?',
                                  hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
                                  border: InputBorder.none, isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                ),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Trip Type ──
            const Row(children: [
              Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF2B3EE6)),
              SizedBox(width: 8),
              Text('When do you need it?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _TripTypeCard(icon: Icons.flash_on_rounded, label: 'Instant', sublabel: 'Right now', selected: _tripType == 'instant', color: const Color(0xFFFF3B30), onTap: () => setState(() => _tripType = 'instant'))),
                const SizedBox(width: 12),
                Expanded(child: _TripTypeCard(icon: Icons.calendar_today_rounded, label: 'Scheduled', sublabel: 'Pick date & time', selected: _tripType == 'scheduled', color: const Color(0xFF2B3EE6), onTap: () => setState(() => _tripType = 'scheduled'))),
              ],
            ),

            if (_tripType == 'scheduled') ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _scheduledDate != null ? const Color(0xFF2B3EE6) : const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, color: _scheduledDate != null ? const Color(0xFF2B3EE6) : const Color(0xFFAAAAAA)),
                      const SizedBox(width: 12),
                      Text(_scheduledLabel, style: TextStyle(fontSize: 14, color: _scheduledDate != null ? const Color(0xFF1A1A2E) : const Color(0xFFAAAAAA), fontWeight: _scheduledDate != null ? FontWeight.w600 : FontWeight.normal)),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Color(0xFFAAAAAA)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Notes ──
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
              child: TextField(
                controller: _notesCtrl, maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Additional notes (optional) — e.g. patient on stretcher...',
                  hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                  border: InputBorder.none, contentPadding: EdgeInsets.all(14),
                  prefixIcon: Icon(Icons.notes_rounded, color: Color(0xFFAAAAAA), size: 20),
                ),
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
              ),
            ),

            const SizedBox(height: 24),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                ]),
              ),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search_rounded),
                label: Text(_loading ? 'Sending...' : 'Find Ambulance', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30), foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TripTypeCard extends StatelessWidget {
  final IconData icon; final String label, sublabel; final bool selected; final Color color; final VoidCallback onTap;
  const _TripTypeCard({required this.icon, required this.label, required this.sublabel, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : const Color(0xFFEEEEEE), width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Icon(icon, color: selected ? color : const Color(0xFFAAAAAA), size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? color : const Color(0xFF1A1A2E))),
          Text(sublabel, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
        ]),
      ),
    );
  }
}
