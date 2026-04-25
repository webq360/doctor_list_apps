import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';
import '../../doctors/screens/doctor_detail_screen.dart';
import 'service_detail_screen.dart';

class HospitalDetailScreen extends StatefulWidget {
  final HospitalModel hospital;
  const HospitalDetailScreen({super.key, required this.hospital});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  int _tab = 0;

  List<DoctorModel> _doctors = [];
  List<AmbulanceModel> _ambulances = [];
  List<HospitalServiceModel> _services = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchTab(0);
  }

  Future<void> _fetchTab(int tab) async {
    setState(() { _loading = true; _tab = tab; });
    try {
      final id = widget.hospital.id;
      if (tab == 0) {
        final res = await ApiClient.dio.get('/hospitals/$id/doctors');
        final list = (res.data as List).map((d) => DoctorModel.fromJson(d as Map<String, dynamic>)).toList();
        if (mounted) setState(() { _doctors = list; _loading = false; });
      } else if (tab == 1) {
        final res = await ApiClient.dio.get('/hospitals/$id/services');
        final list = (res.data as List).map((s) => HospitalServiceModel.fromJson(s as Map<String, dynamic>)).toList();
        if (mounted) setState(() { _services = list; _loading = false; });
      } else {
        final res = await ApiClient.dio.get('/hospitals/$id/ambulances');
        final list = (res.data as List).map((a) => AmbulanceModel.fromJson(a as Map<String, dynamic>)).toList();
        if (mounted) setState(() { _ambulances = list; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _TopSection(hospital: widget.hospital),
          _TabBar(selected: _tab, onTap: _fetchTab),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tab == 0
                    ? _DoctorTab(doctors: _doctors)
                    : _tab == 1
                        ? _ServiceTab(services: _services)
                        : _AmbulanceTab(ambulances: _ambulances),
          ),
        ],
      ),
    );
  }
}

// ── Top Section ──
class _TopSection extends StatelessWidget {
  final HospitalModel hospital;
  const _TopSection({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: hospital.imageUrl != null
                  ? Image.network(hospital.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFB0BEC5),
                        child: const Center(child: Icon(Icons.local_hospital_rounded, size: 72, color: Colors.white54)),
                      ))
                  : Container(
                      color: const Color(0xFFB0BEC5),
                      child: const Center(child: Icon(Icons.local_hospital_rounded, size: 72, color: Colors.white54)),
                    ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))
                    ],
                  ),
                  child: ClipOval(
                    child: hospital.logoUrl != null
                        ? Image.network(hospital.logoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital_rounded, color: Color(0xFF2B3EE6), size: 36))
                        : const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.local_hospital_rounded, color: Color(0xFF2B3EE6), size: 36),
                          ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(hospital.address,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab Bar ──
class _TabBar extends StatelessWidget {
  final int selected;
  final void Function(int) onTap;
  const _TabBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = ['Doctor', 'Service', 'Ambulance'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2B3EE6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(tabs[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : const Color(0xFF888888),
                      )),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Doctor Tab ──
class _DoctorTab extends StatelessWidget {
  final List<DoctorModel> doctors;
  const _DoctorTab({required this.doctors});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(child: Text('No doctors assigned', style: TextStyle(color: Color(0xFFAAAAAA))));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: doctors.length,
      itemBuilder: (_, i) => _DoctorCard(
        doctor: doctors[i],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctors[i]))),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text(doctor.specialization,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text('${doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : "N/A"} (${doctor.ratingCount})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                        const SizedBox(width: 10),
                        Text('Fee ${doctor.fees.toInt()}/-',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B3EE6))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doctor.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(doctor.bio, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.5)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2B3EE6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
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
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('Appointment',
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

// ── Service Tab ──
class _ServiceTab extends StatelessWidget {
  final List<HospitalServiceModel> services;
  const _ServiceTab({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('No services available', style: TextStyle(color: Color(0xFFAAAAAA))));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 150,
      ),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: s))),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: s.iconUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(s.iconUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.medical_services_outlined, color: Color(0xFF2B3EE6), size: 26)))
                      : const Icon(Icons.medical_services_outlined, color: Color(0xFF2B3EE6), size: 26),
                ),
                const SizedBox(height: 10),
                Text(s.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(s.shortTitle ?? s.about ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Ambulance Tab ──
class _AmbulanceTab extends StatelessWidget {
  final List<AmbulanceModel> ambulances;
  const _AmbulanceTab({required this.ambulances});

  @override
  Widget build(BuildContext context) {
    if (ambulances.isEmpty) {
      return const Center(child: Text('No ambulances assigned', style: TextStyle(color: Color(0xFFAAAAAA))));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: ambulances.length,
      itemBuilder: (_, i) {
        final a = ambulances[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: a.driverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(a.driverImage!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.airport_shuttle_rounded, color: Color(0xFFFF6B35), size: 28)))
                    : const Icon(Icons.airport_shuttle_rounded, color: Color(0xFFFF6B35), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.driverName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 3),
                    Text(a.vehicleNumber,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    Text(a.ambulanceType,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2B3EE6))),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone, size: 14),
                label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3EE6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
