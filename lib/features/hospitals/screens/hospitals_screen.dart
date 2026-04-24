import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import 'hospital_detail_screen.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final _searchCtrl = TextEditingController();

  static final _allHospitals = [
    HospitalModel(id: '1', name: 'Dhaka Medical College Hospital', address: 'Bakshibazar, Dhaka', lat: 23.7261, lng: 90.3963, contact: '02-55165088', distance: 1.2),
    HospitalModel(id: '2', name: 'Square Hospital Ltd', address: 'West Panthapath, Dhaka', lat: 23.7512, lng: 90.3773, contact: '10616', distance: 2.5),
    HospitalModel(id: '3', name: 'Popular Medical Centre', address: 'Shyamoli, Dhaka', lat: 23.7731, lng: 90.3584, contact: '01713-066666', distance: 3.8),
    HospitalModel(id: '4', name: 'National Institute of Neurosciences', address: 'Agargaon, Dhaka', lat: 23.7775, lng: 90.3667, contact: '02-9118541', distance: 4.1),
    HospitalModel(id: '5', name: 'Chittagong Medical College Hospital', address: 'K.B. Fazlul Kader Road, Chittagong', lat: 22.3569, lng: 91.8324, contact: '031-630954'),
    HospitalModel(id: '6', name: 'Sylhet MAG Osmani Medical College', address: 'Sylhet Sadar, Sylhet', lat: 24.8949, lng: 91.8687, contact: '0821-716476'),
  ];

  List<HospitalModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allHospitals;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allHospitals
          : _allHospitals
              .where((h) =>
                  h.name.toLowerCase().contains(q) ||
                  h.address.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _HospitalHeader(searchCtrl: _searchCtrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Hospitals',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                Text('${_filtered.length} found',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_hospital_outlined,
                            size: 64, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text('No hospitals found',
                            style: TextStyle(
                                color: Color(0xFFAAAAAA), fontSize: 15)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _HospitalCard(
                      hospital: _filtered[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HospitalDetailScreen(hospital: _filtered[i]),
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
  const _HospitalHeader({required this.searchCtrl});

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
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search hospital or address...',
                    hintStyle:
                        TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                    prefixIcon:
                        Icon(Icons.search, size: 20, color: Color(0xFFAAAAAA)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    isDense: true,
                  ),
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
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
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
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
              child: const Icon(Icons.local_hospital_rounded,
                  color: Color(0xFF2B3EE6), size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(hospital.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                      ),
                      if (hospital.distance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.near_me,
                                  size: 11, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 3),
                              Text(
                                '${hospital.distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF888888)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(hospital.address,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888888)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined, size: 14),
                          label: Text(hospital.contact,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2B3EE6),
                            side: const BorderSide(color: Color(0xFF2B3EE6)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward_outlined,
                              size: 14),
                          label: const Text('Details',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B3EE6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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
