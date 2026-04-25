import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/bd_location_data.dart';
import 'hospital_detail_screen.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final _searchCtrl = TextEditingController();
  List<HospitalModel> _hospitals = [];
  bool _loading = true;
  String? _error;
  String? _division;
  String? _district;
  String? _upazila;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchHospitals() async {
    setState(() { _loading = true; _error = null; });
    try {
      final params = <String, dynamic>{};
      final name = _searchCtrl.text.trim();
      if (name.isNotEmpty) params['name'] = name;
      if (_division != null) params['division'] = _division;
      if (_district != null) params['district'] = _district;
      if (_upazila != null) params['upazila'] = _upazila;

      final res = await ApiClient.dio.get('/hospitals', queryParameters: params.isNotEmpty ? params : null);
      final list = (res.data as List).map((h) => HospitalModel.fromJson(h as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _hospitals = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load hospitals'; _loading = false; });
    }
  }

  void _openLocationPicker() async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationPickerSheet(
        initialDivision: _division,
        initialDistrict: _district,
        initialUpazila: _upazila,
      ),
    );
    if (result != null) {
      setState(() {
        _division = result['division'];
        _district = result['district'];
        _upazila = result['upazila'];
      });
      _fetchHospitals();
    }
  }

  String get _locationLabel {
    if (_upazila != null) return _upazila!;
    if (_district != null) return _district!;
    if (_division != null) return _division!;
    return 'Location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _HospitalHeader(
            searchCtrl: _searchCtrl,
            locationLabel: _locationLabel,
            hasLocation: _division != null,
            onLocationTap: _openLocationPicker,
            onSearch: _fetchHospitals,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Hospitals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Row(
                  children: [
                    Text('${_hospitals.length} found',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                    if (_division != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() { _division = null; _district = null; _upazila = null; });
                          _fetchHospitals();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEE8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Text('Clear', style: TextStyle(fontSize: 11, color: Color(0xFFFF6B35))),
                              SizedBox(width: 3),
                              Icon(Icons.close, size: 11, color: Color(0xFFFF6B35)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchHospitals, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _hospitals.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_hospital_outlined, size: 64, color: Color(0xFFCCCCCC)),
                                SizedBox(height: 12),
                                Text('No hospitals found', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchHospitals,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: _hospitals.length,
                              itemBuilder: (_, i) => _HospitalCard(
                                hospital: _hospitals[i],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => HospitalDetailScreen(hospital: _hospitals[i])),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Header ──
class _HospitalHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String locationLabel;
  final bool hasLocation;
  final VoidCallback onLocationTap;
  final VoidCallback onSearch;

  const _HospitalHeader({
    required this.searchCtrl,
    required this.locationLabel,
    required this.hasLocation,
    required this.onLocationTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4158F5), Color(0xFF2B3EE6)],
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hospitals',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: searchCtrl,
                        onSubmitted: (_) => onSearch(),
                        decoration: const InputDecoration(
                          hintText: 'Search hospital...',
                          hintStyle: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFFAAAAAA)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 18,
                              color: hasLocation ? const Color(0xFF2B3EE6) : const Color(0xFFAAAAAA)),
                          const SizedBox(width: 6),
                          Text(
                            locationLabel,
                            style: TextStyle(
                              fontSize: 13,
                              color: hasLocation ? const Color(0xFF1A1A2E) : const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFFAAAAAA)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hospital Card ──
class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onTap;
  const _HospitalCard({required this.hospital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: hospital.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(hospital.logoUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.local_hospital_rounded, color: Color(0xFF2B3EE6), size: 30)))
                  : const Icon(Icons.local_hospital_rounded, color: Color(0xFF2B3EE6), size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospital.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF888888)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(hospital.address,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  if (hospital.division != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 12, color: Color(0xFF2B3EE6)),
                        const SizedBox(width: 4),
                        Text(
                          [hospital.division, hospital.district, hospital.upazila]
                              .where((e) => e != null && e.isNotEmpty)
                              .join(', '),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF2B3EE6)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined, size: 14),
                          label: Text(hospital.contact,
                              style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2B3EE6),
                            side: const BorderSide(color: Color(0xFF2B3EE6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward_outlined, size: 14),
                          label: const Text('Details', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B3EE6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location Picker Sheet ──
class _LocationPickerSheet extends StatefulWidget {
  final String? initialDivision;
  final String? initialDistrict;
  final String? initialUpazila;

  const _LocationPickerSheet({
    this.initialDivision,
    this.initialDistrict,
    this.initialUpazila,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  String? _division;
  String? _district;
  String? _upazila;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _division = widget.initialDivision;
    _district = widget.initialDistrict;
    _upazila = widget.initialUpazila;
    if (_division != null && _district != null) {
      _step = 2;
    } else if (_division != null) {
      _step = 1;
    }
  }

  List<String> get _currentItems {
    if (_step == 0) return bdLocations.keys.toList();
    if (_step == 1) return bdLocations[_division]!.keys.toList();
    return bdLocations[_division]![_district]!;
  }

  String get _stepTitle {
    if (_step == 0) return 'Select Division';
    if (_step == 1) return 'Select District';
    return 'Select Upazila';
  }

  void _onSelect(String value) {
    if (_step == 0) {
      setState(() { _division = value; _district = null; _upazila = null; _step = 1; });
    } else if (_step == 1) {
      setState(() { _district = value; _upazila = null; _step = 2; });
    } else {
      Navigator.pop(context, {'division': _division, 'district': _district, 'upazila': value});
    }
  }

  void _goBack() {
    if (_step == 1) {
      setState(() { _step = 0; _division = null; });
    } else if (_step == 2) {
      setState(() { _step = 1; _district = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                if (_step > 0)
                  GestureDetector(
                    onTap: _goBack,
                    child: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF2B3EE6)),
                  ),
                if (_step > 0) const SizedBox(width: 8),
                Text(_stepTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const Spacer(),
                if (_division != null)
                  Text(
                    _district != null ? '$_division › $_district' : _division!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _currentItems.length,
              itemBuilder: (_, i) {
                final item = _currentItems[i];
                final isSelected = (_step == 0 && item == _division) ||
                    (_step == 1 && item == _district) ||
                    (_step == 2 && item == _upazila);
                return ListTile(
                  dense: true,
                  title: Text(item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF2B3EE6) : const Color(0xFF1A1A2E),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      )),
                  trailing: _step < 2
                      ? const Icon(Icons.chevron_right, size: 18, color: Color(0xFFAAAAAA))
                      : isSelected
                          ? const Icon(Icons.check, size: 18, color: Color(0xFF2B3EE6))
                          : null,
                  onTap: () => _onSelect(item),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
            child: TextButton(
              onPressed: () => Navigator.pop(context, {'division': null, 'district': null, 'upazila': null}),
              child: const Text('Clear Location', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
