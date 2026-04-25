import 'package:flutter/material.dart';
import '../../doctors/screens/doctor_detail_screen.dart';
import '../../../core/models/models.dart';

class ServiceDetailScreen extends StatelessWidget {
  final HospitalServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _Header(service: service),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.about != null && service.about!.isNotEmpty) ...[
                    _SectionCard(
                      title: 'About',
                      child: Text(service.about!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6)),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (service.whatWeOffer.isNotEmpty) ...[
                    _SectionCard(
                      title: 'What We Offer',
                      child: Column(
                        children: service.whatWeOffer.map((f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF0FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check, size: 16, color: Color(0xFF2B3EE6)),
                              ),
                              const SizedBox(width: 12),
                              Text(f, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (service.availableDoctors.isNotEmpty) ...[
                    const Text('Available Doctors',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 10),
                    ...service.availableDoctors.map((d) => _SmallDoctorCard(
                          doctor: d,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: d))),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  final HospitalServiceModel service;
  const _Header({required this.service});

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text('Service Details',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: service.iconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(service.iconUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.medical_services_outlined, color: Colors.white, size: 38)))
                    : const Icon(Icons.medical_services_outlined, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 12),
              Text(service.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              if (service.shortTitle != null) ...[
                const SizedBox(height: 4),
                Text(service.shortTitle!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Card ──
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Small Doctor Card ──
class _SmallDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  const _SmallDoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFB347), width: 2),
                color: const Color(0xFFFFE0CC),
              ),
              child: ClipOval(
                child: doctor.imageUrl != null
                    ? Image.network(doctor.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFFFF8C42), size: 28))
                    : const Icon(Icons.person, color: Color(0xFFFF8C42), size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  Text(doctor.specialization,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text('${doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : "N/A"} (${doctor.ratingCount})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                      const SizedBox(width: 10),
                      Text('Fee ${doctor.fees.toInt()}/-',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B3EE6))),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
          ],
        ),
      ),
    );
  }
}
