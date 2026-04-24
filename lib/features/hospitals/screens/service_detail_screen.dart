import 'package:flutter/material.dart';
import '../../doctors/screens/doctor_detail_screen.dart';
import '../../../core/models/models.dart';

class ServiceDetailScreen extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;

  const ServiceDetailScreen({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
  });

  static final _serviceDetails = {
    'Cardiology': _ServiceInfo(
      about: 'Cardiology is a branch of medicine that deals with disorders of the heart and the cardiovascular system. The field includes medical diagnosis and treatment of congenital heart defects, coronary artery disease, heart failure, valvular heart disease and electrophysiology.',
      features: ['ECG & Echo', 'Angiography', 'Heart Surgery', 'Pacemaker', 'Cardiac Rehab'],
      doctors: [
        DoctorModel(id: 'c1', name: 'Dr. Arif Hossain', specialization: 'Cardiologist', experience: 12, fees: 800, bio: 'Specialist in heart diseases with 12 years of experience.', isApproved: true, location: 'Dhaka', rating: 4.8, ratingCount: 124),
        DoctorModel(id: 'c2', name: 'Dr. Kamal Uddin', specialization: 'Cardiologist', experience: 9, fees: 700, bio: 'Expert in interventional cardiology and heart failure management.', isApproved: true, location: 'Dhaka', rating: 4.6, ratingCount: 88),
      ],
    ),
    'Neurology': _ServiceInfo(
      about: 'Neurology is a branch of medicine dealing with disorders of the nervous system. Neurology deals with the diagnosis and treatment of all categories of conditions and disease involving the central and peripheral nervous system.',
      features: ['MRI & CT Scan', 'EEG', 'Stroke Care', 'Epilepsy Treatment', 'Nerve Study'],
      doctors: [
        DoctorModel(id: 'n1', name: 'Dr. Rakibul Islam', specialization: 'Neurologist', experience: 15, fees: 1000, bio: 'Senior neurologist with expertise in stroke and epilepsy management.', isApproved: true, location: 'Dhaka', rating: 4.9, ratingCount: 210),
      ],
    ),
    'Pediatrics': _ServiceInfo(
      about: 'Pediatrics is the branch of medicine that involves the medical care of infants, children, adolescents, and young adults. The word pediatrics means healer of children.',
      features: ['Newborn Care', 'Vaccination', 'Growth Monitoring', 'Child Nutrition', 'Fever & Infection'],
      doctors: [
        DoctorModel(id: 'p1', name: 'Dr. Fatema Begum', specialization: 'Pediatrician', experience: 10, fees: 600, bio: 'Dedicated to providing comprehensive healthcare for children from birth to adolescence.', isApproved: true, location: 'Dhaka', rating: 4.7, ratingCount: 165),
      ],
    ),
    'Gynecology': _ServiceInfo(
      about: 'Gynecology is the medical practice dealing with the health of the female reproductive system. It covers a wide range of issues including menstruation, fertility, sexually transmitted infections, hormonal disorders, and more.',
      features: ['Antenatal Care', 'Normal Delivery', 'C-Section', 'Ultrasound', 'Family Planning'],
      doctors: [
        DoctorModel(id: 'g1', name: 'Dr. Nusrat Jahan', specialization: 'Gynecologist', experience: 8, fees: 600, bio: 'Expert in women health and maternity care. Visiting at Popular Hospital.', isApproved: true, location: 'Chittagong', rating: 4.6, ratingCount: 98),
      ],
    ),
    'Orthopedics': _ServiceInfo(
      about: 'Orthopedics is a medical specialty that focuses on the diagnosis, correction, prevention, and treatment of patients with skeletal deformities — disorders of the bones, joints, muscles, ligaments, tendons, nerves and skin.',
      features: ['Fracture Care', 'Joint Replacement', 'Sports Injury', 'Spine Surgery', 'Physiotherapy'],
      doctors: [
        DoctorModel(id: 'o1', name: 'Dr. Mahbub Alam', specialization: 'Orthopedic', experience: 10, fees: 750, bio: 'Bone and joint specialist. Experienced in sports injury and fracture care.', isApproved: true, location: 'Rajshahi', rating: 4.7, ratingCount: 155),
      ],
    ),
    'Pathology': _ServiceInfo(
      about: 'Pathology is the study of the causes and effects of disease or injury. It involves examining tissues, organs, bodily fluids, and autopsies in order to study and diagnose disease.',
      features: ['Blood Tests', 'Urine Analysis', 'Biopsy', 'Culture & Sensitivity', 'Hormone Tests'],
      doctors: [
        DoctorModel(id: 'pa1', name: 'Dr. Sumaiya Akter', specialization: 'Pathologist', experience: 6, fees: 500, bio: 'Specialist in clinical pathology and laboratory diagnostics.', isApproved: true, location: 'Sylhet', rating: 4.5, ratingCount: 76),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final info = _serviceDetails[name];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _Header(icon: icon, name: name, description: description),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About
                  _SectionCard(
                    title: 'About',
                    child: Text(
                      info?.about ?? description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Features
                  if (info != null) ...[
                    _SectionCard(
                      title: 'What We Offer',
                      child: Column(
                        children: info.features
                            .map((f) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF0FF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.check,
                                            size: 16,
                                            color: Color(0xFF2B3EE6)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(f,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF1A1A2E))),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Doctors
                    const Text('Available Doctors',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 10),
                    ...info.doctors.map((d) => _SmallDoctorCard(
                          doctor: d,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DoctorDetailScreen(doctor: d)),
                          ),
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

class _ServiceInfo {
  final String about;
  final List<String> features;
  final List<DoctorModel> doctors;
  const _ServiceInfo(
      {required this.about,
      required this.features,
      required this.doctors});
}

// ── Header ──
class _Header extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  const _Header(
      {required this.icon, required this.name, required this.description});

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
              // Back button row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text('Service Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
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
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFB347), width: 2),
                color: const Color(0xFFFFE0CC),
              ),
              child: const Icon(Icons.person,
                  color: Color(0xFFFF8C42), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  Text(doctor.specialization,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(
                        '${doctor.rating.toStringAsFixed(1)} (${doctor.ratingCount})',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                      ),
                      const SizedBox(width: 10),
                      Text('Fee ${doctor.fees.toInt()}/-',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B3EE6))),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFAAAAAA), size: 20),
          ],
        ),
      ),
    );
  }
}
