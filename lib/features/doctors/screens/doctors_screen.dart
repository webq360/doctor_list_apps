import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/bd_location_data.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<DoctorModel> _doctors = [];
  bool _loading = false;
  String? _error;

  static const _dummyDoctors = [
    (
      '1', 'Dr. Arif Hossain', 'Cardiologist', 12, 800.0,
      'Specialist in heart diseases with 12 years of experience at DMCH.',
      'Dhaka', 4.8, 124, 'Dhaka Medical College Hospital',
    ),
    (
      '2', 'Dr. Nusrat Jahan', 'Gynecologist', 8, 600.0,
      'Expert in women health and maternity care. Visiting at Popular Hospital.',
      'Chittagong', 4.6, 98, 'Popular Medical Centre',
    ),
    (
      '3', 'Dr. Rakibul Islam', 'Neurologist', 15, 1000.0,
      'Senior neurologist with expertise in stroke and epilepsy management.',
      'Dhaka', 4.9, 210, 'National Institute of Neurosciences',
    ),
    (
      '4', 'Dr. Sumaiya Akter', 'Dermatologist', 6, 500.0,
      'Skin specialist treating acne, eczema and cosmetic skin conditions.',
      'Sylhet', 4.5, 76, 'Sylhet MAG Osmani Medical College',
    ),
    (
      '5', 'Dr. Mahbub Alam', 'Orthopedic', 10, 750.0,
      'Bone and joint specialist. Experienced in sports injury and fracture care.',
      'Rajshahi', 4.7, 155, 'Rajshahi Medical College Hospital',
    ),
  ];
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  String? _division;
  String? _district;
  String? _upazila;

  @override
  void initState() {
    super.initState();
    _loadDummy();
  }

  void _loadDummy() {
    _doctors = _dummyDoctors
        .map((d) => DoctorModel(
              id: d.$1,
              name: d.$2,
              specialization: d.$3,
              experience: d.$4,
              fees: d.$5,
              bio: d.$6,
              isApproved: true,
              location: d.$7,
              rating: d.$8,
              ratingCount: d.$9,
              hospital: d.$10,
            ))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final name = _nameCtrl.text.trim().toLowerCase();
    final dept = _deptCtrl.text.trim().toLowerCase();
    final loc = _upazila ?? _district ?? _division;
    setState(() {
      _doctors = _dummyDoctors
          .where((d) =>
              (name.isEmpty || d.$2.toLowerCase().contains(name)) &&
              (dept.isEmpty || d.$3.toLowerCase().contains(dept)) &&
              (loc == null || d.$7.toLowerCase().contains(loc.toLowerCase())))
          .map((d) => DoctorModel(
                id: d.$1, name: d.$2, specialization: d.$3,
                experience: d.$4, fees: d.$5, bio: d.$6,
                isApproved: true, location: d.$7, rating: d.$8, ratingCount: d.$9,
                hospital: d.$10,
              ))
          .toList();
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _SearchHeader(
            nameCtrl: _nameCtrl,
            deptCtrl: _deptCtrl,
            division: _division,
            district: _district,
            upazila: _upazila,
            onLocationTap: _openLocationPicker,
            onSearch: _search,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Doctor List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Text('More',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2B3EE6), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _doctors.isEmpty
                        ? const Center(child: Text('No doctors found'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _doctors.length,
                            itemBuilder: (_, i) => _DoctorCard(
                              doctor: _doctors[i],
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: _doctors[i]))),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Search Header ──
class _SearchHeader extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController deptCtrl;
  final String? division;
  final String? district;
  final String? upazila;
  final VoidCallback onLocationTap;
  final VoidCallback onSearch;

  const _SearchHeader({
    required this.nameCtrl,
    required this.deptCtrl,
    required this.division,
    required this.district,
    required this.upazila,
    required this.onLocationTap,
    required this.onSearch,
  });

  String get _locationLabel {
    if (upazila != null) return upazila!;
    if (district != null) return district!;
    if (division != null) return division!;
    return 'Location';
  }

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
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: nameCtrl,
                      hint: 'Doctor Name',
                      icon: Icons.search,
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onLocationTap,
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF2B3EE6)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _locationLabel,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: division == null ? const Color(0xFFAAAAAA) : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFFAAAAAA)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SearchField(
                controller: deptCtrl,
                hint: "Doctor's Department",
                icon: Icons.search,
                onSubmitted: (_) => onSearch(),
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onSubmitted;
  final IconData? suffixIcon;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFFAAAAAA)),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, size: 20, color: const Color(0xFFAAAAAA))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
      ),
    );
  }
}


class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: avatar + name + specialty + location + short bio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB347), width: 2),
                  color: const Color(0xFFFFE0CC),
                ),
                child: ClipOval(
                  child: doctor.imageUrl != null
                      ? Image.network(doctor.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFFFF8C42), size: 32))
                      : const Icon(Icons.person, color: Color(0xFFFF8C42), size: 32),
                ),
              ),
              const SizedBox(width: 12),
              // Name + specialty + location + bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(doctor.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        if (doctor.location.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF2B3EE6)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 11, color: Color(0xFF2B3EE6)),
                                const SizedBox(width: 3),
                                Text(doctor.location,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF2B3EE6))),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(doctor.specialization,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    if (doctor.hospital != null) ...[
                      const SizedBox(height: 4),
                      Text(doctor.hospital!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    ],

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            doctor.bio.isNotEmpty
                ? doctor.bio
                : '8 year experience" refers to a significant amount of professional work in a specific field, suggesting a candidate has a strong track record of skills and knowledge. For someone with this level of experience',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.5),
          ),
          const SizedBox(height: 10),
          // Rating + experience + fee row
          Row(
            children: [
              const Icon(Icons.star, size: 15, color: Color(0xFFFFC107)),
              const SizedBox(width: 3),
              Text(
                '${doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : "4.5"} (${doctor.ratingCount > 0 ? doctor.ratingCount : 7})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.people_outline, size: 15, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Text('${doctor.experience} year experience',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              const Spacer(),
              Text('Fee ${doctor.fees.toInt()}/-',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2B3EE6))),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2B3EE6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Details',
                      style: TextStyle(fontSize: 13, color: Color(0xFF2B3EE6), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B3EE6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('appointment',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Location Picker Bottom Sheet ──
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

  // 0 = Division, 1 = District, 2 = Upazila
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _division = widget.initialDivision;
    _district = widget.initialDistrict;
    _upazila = widget.initialUpazila;
    if (_division != null && _district != null) _step = 2;
    else if (_division != null) _step = 1;
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
      _upazila = value;
      Navigator.pop(context, {'division': _division, 'district': _district, 'upazila': _upazila});
    }
  }

  void _goBack() {
    if (_step == 1) setState(() { _step = 0; _division = null; });
    else if (_step == 2) setState(() { _step = 1; _district = null; });
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)),
          ),
          // Header
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
                // Breadcrumb
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
          // List
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
          // Clear button
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
