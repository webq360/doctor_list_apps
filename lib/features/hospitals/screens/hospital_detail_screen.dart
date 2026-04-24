import 'package:flutter/material.dart';
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

  static final _doctors = [
    DoctorModel(id: '1', name: 'Dr. Arif Hossain', specialization: 'Ora; Health Specialty', experience: 8, fees: 600, bio: '8 year experience refers to a significant amount of professional work in a specific field, suggesting a candidate has a strong track record of skills and knowledge. For someone with this level of experience', isApproved: true, location: 'Faridpur', rating: 4.5, ratingCount: 7),
    DoctorModel(id: '2', name: 'Dr. Nusrat Jahan', specialization: 'Ora; Health Specialty', experience: 10, fees: 800, bio: '8 year experience refers to a significant amount of professional work in a specific field, suggesting a candidate has a strong track record of skills and knowledge. For someone with this level of experience', isApproved: true, location: 'Faridpur', rating: 4.5, ratingCount: 7),
    DoctorModel(id: '3', name: 'Dr. Rakibul Islam', specialization: 'Ora; Health Specialty', experience: 12, fees: 1000, bio: '8 year experience refers to a significant amount of professional work in a specific field, suggesting a candidate has a strong track record of skills and knowledge. For someone with this level of experience', isApproved: true, location: 'Faridpur', rating: 4.8, ratingCount: 15),
  ];

  static const _services = [
    (Icons.favorite_border, 'Cardiology', 'Heart & cardiovascular care'),
    (Icons.psychology_outlined, 'Neurology', 'Brain & nervous system'),
    (Icons.child_care_outlined, 'Pediatrics', 'Children healthcare'),
    (Icons.pregnant_woman_outlined, 'Gynecology', 'Women health & maternity'),
    (Icons.healing_outlined, 'Orthopedics', 'Bone & joint treatment'),
    (Icons.biotech_outlined, 'Pathology', 'Lab & diagnostic services'),
  ];

  static const _ambulances = [
    ('Mohsin', '01711-XXXXXX', 'Dhaka Metro-GA 1234'),
    ('Sani', '01811-XXXXXX', 'Dhaka Metro-GA 5678'),
    ('Nazmul', '01911-XXXXXX', 'Dhaka Metro-GA 9012'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _TopSection(hospital: widget.hospital),
          _TabBar(selected: _tab, onTap: (i) => setState(() => _tab = i)),
          Expanded(
            child: _tab == 0
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
        // Hospital image with back button
        Stack(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/hospital.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFB0BEC5),
                  child: const Center(
                    child: Icon(Icons.local_hospital_rounded,
                        size: 72, color: Colors.white54),
                  ),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),

        // White background info section
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo circle overlapping image
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
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/hospital_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_hospital_rounded,
                          color: Color(0xFF2B3EE6),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Name
              Transform.translate(
                offset: const Offset(0, -20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(
                          hospital.address,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF888888)),
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
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
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
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : const Color(0xFF888888),
                    ),
                  ),
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: doctors.length,
      itemBuilder: (_, i) => _DoctorCard(
        doctor: doctors[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DoctorDetailScreen(doctor: doctors[i])),
        ),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: avatar + name + specialty
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
                child: const Icon(Icons.person,
                    color: Color(0xFFFF8C42), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text(doctor.specialization,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                    const SizedBox(height: 6),
                    // Rating + short bio inline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(
                          '${doctor.rating.toStringAsFixed(1)} (${doctor.ratingCount})',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'professional work in a specific field, suggesting a candidate has a strong track',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bio full
          Text(
            doctor.bio,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF555555), height: 1.5),
          ),
          const SizedBox(height: 10),
          // Stats row: experience + fee + location
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 15, color: Color(0xFF888888)),
              const SizedBox(width: 4),
              Text('${doctor.experience} year +',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF555555))),
              const SizedBox(width: 16),
              Text('Fee ${doctor.fees.toInt()}/-',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3EE6))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2B3EE6)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: Color(0xFF2B3EE6)),
                    const SizedBox(width: 3),
                    Text(doctor.location,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF2B3EE6))),
                  ],
                ),
              ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('Details',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2B3EE6),
                          fontWeight: FontWeight.w600)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('appointment',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
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
  final List<(IconData, String, String)> services;
  const _ServiceTab({required this.services});

  @override
  Widget build(BuildContext context) {
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(
                icon: s.$1,
                name: s.$2,
                description: s.$3,
              ),
            ),
          ),
          child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
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
                child: Icon(s.$1, color: const Color(0xFF2B3EE6), size: 26),
              ),
              const SizedBox(height: 10),
              Text(s.$2,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Text(s.$3,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888))),
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
  final List<(String, String, String)> ambulances;
  const _AmbulanceTab({required this.ambulances});

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
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
                child: const Icon(Icons.airport_shuttle_rounded,
                    color: Color(0xFFFF6B35), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.$1,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 3),
                    Text(a.$3,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone, size: 14),
                label: const Text('Call',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3EE6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
