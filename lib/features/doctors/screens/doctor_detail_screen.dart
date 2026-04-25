import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _Header(doctor: doctor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(doctor: doctor),
                  const SizedBox(height: 16),
                  _InfoCard(doctor: doctor),
                  const SizedBox(height: 16),
                  _AboutCard(doctor: doctor),
                  const SizedBox(height: 16),
                  _ScheduleCard(schedule: doctor.schedule),
                  const SizedBox(height: 16),
                  _RatingCard(doctor: doctor),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(doctor: doctor),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  final DoctorModel doctor;
  const _Header({required this.doctor});

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text('Doctor Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: const Color(0xFFFFE0CC),
                ),
                child: ClipOval(
                  child: doctor.imageUrl != null
                      ? Image.network(doctor.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Color(0xFFFF8C42), size: 48))
                      : const Icon(Icons.person, color: Color(0xFFFF8C42), size: 48),
                ),
              ),
              const SizedBox(height: 12),
              Text(doctor.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(doctor.specialization,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (doctor.hospital != null && doctor.hospital!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(doctor.hospital!,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 8),
              if (doctor.location.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(doctor.location,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats Row ──
class _StatsRow extends StatelessWidget {
  final DoctorModel doctor;
  const _StatsRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFFC107),
          value: doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '—',
          label: 'Rating',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.people_outline,
          iconColor: const Color(0xFF2B3EE6),
          value: '${doctor.ratingCount}+',
          label: 'Reviews',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.work_outline,
          iconColor: const Color(0xFF2B3EE6),
          value: '${doctor.experience}yr',
          label: 'Experience',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.monetization_on_outlined,
          iconColor: const Color(0xFF4CAF50),
          value: '৳${doctor.fees.toInt()}',
          label: 'Fee',
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatBox({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ──
class _InfoCard extends StatelessWidget {
  final DoctorModel doctor;
  const _InfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Information', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          if (doctor.hospital != null && doctor.hospital!.isNotEmpty)
            _InfoRow(icon: Icons.local_hospital_outlined, label: 'Hospital', value: doctor.hospital!),
          _InfoRow(icon: Icons.medical_services_outlined, label: 'Specialization', value: doctor.specialization.isNotEmpty ? doctor.specialization : '—'),
          if (doctor.location.isNotEmpty)
            _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: doctor.location),
          _InfoRow(icon: Icons.monetization_on_outlined, label: 'Consultation Fee', value: '৳${doctor.fees.toInt()}'),
          _InfoRow(icon: Icons.access_time, label: 'Experience', value: '${doctor.experience} Years'),
          _InfoRow(
            icon: Icons.verified_outlined,
            label: 'Status',
            value: doctor.isApproved ? 'Verified' : 'Pending',
            valueColor: doctor.isApproved ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2B3EE6)),
          const SizedBox(width: 10),
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF888888)))),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1A1A2E))),
          ),
        ],
      ),
    );
  }
}

// ── About Card ──
class _AboutCard extends StatelessWidget {
  final DoctorModel doctor;
  const _AboutCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About Doctor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          Text(
            doctor.bio.isNotEmpty ? doctor.bio : 'No information available.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Schedule Card ──
class _ScheduleCard extends StatelessWidget {
  final List<ScheduleModel> schedule;
  const _ScheduleCard({required this.schedule});

  static const _allDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    final scheduleMap = {for (final s in schedule) s.day: '${s.startTime} – ${s.endTime}'};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          if (schedule.isEmpty)
            const Text('No schedule available', style: TextStyle(fontSize: 13, color: Color(0xFF888888)))
          else
            ..._allDays.map((day) {
              final time = scheduleMap[day];
              final closed = time == null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
                    Text(
                      closed ? 'Closed' : time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: closed ? const Color(0xFFFF5252) : const Color(0xFF2B3EE6),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Rating Card ──
class _RatingCard extends StatefulWidget {
  final DoctorModel doctor;
  const _RatingCard({required this.doctor});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  int _selected = 0;
  bool _submitted = false;
  bool _loading = false;
  double? _newRating;
  int? _newCount;

  Future<void> _submit() async {
    if (_selected == 0) return;
    setState(() => _loading = true);
    try {
      final res = await ApiClient.dio.post('/doctors/${widget.doctor.id}/rate', data: {'rating': _selected});
      setState(() {
        _submitted = true;
        _newRating = (res.data['rating'] as num).toDouble();
        _newCount = res.data['ratingCount'] as int;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Rate this Doctor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const Spacer(),
              if (_newRating != null || widget.doctor.rating > 0)
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '${(_newRating ?? widget.doctor.rating).toStringAsFixed(1)} (${_newCount ?? widget.doctor.ratingCount})',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_submitted)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 36),
                  const SizedBox(height: 8),
                  Text('Thanks for rating $_selected ★',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selected = star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      _selected >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _selected >= star ? const Color(0xFFFFC107) : const Color(0xFFCCCCCC),
                      size: 38,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selected == 0 || _loading) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3EE6),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Rating', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom Bar ──
class _BottomBar extends StatelessWidget {
  final DoctorModel doctor;
  const _BottomBar({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2B3EE6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone_outlined, color: Color(0xFF2B3EE6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showBookingSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B3EE6),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Book Appointment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(doctor: doctor),
    );
  }
}

// ── Booking Bottom Sheet ──
class _BookingSheet extends StatefulWidget {
  final DoctorModel doctor;
  const _BookingSheet({required this.doctor});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String? _selectedDate;
  String? _selectedTime;
  bool _booking = false;

  static const _times = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];

  List<String> get _next7Days {
    final days = <String>[];
    for (int i = 1; i <= 7; i++) {
      final d = DateTime.now().add(Duration(days: i));
      days.add('${d.day}/${d.month}/${d.year}');
    }
    return days;
  }

  Future<void> _confirmBooking() async {
    setState(() => _booking = true);
    try {
      await ApiClient.dio.post('/appointments', data: {
        'doctorId': widget.doctor.id,
        'date': _selectedDate,
        'time': _selectedTime,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked for $_selectedDate at $_selectedTime')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          const Text('Select Date', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _next7Days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = _next7Days[i];
                final selected = d == _selectedDate;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF2B3EE6) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF1A1A2E))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _times.map((t) {
              final selected = t == _selectedTime;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF2B3EE6) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF1A1A2E))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTime != null && !_booking) ? _confirmBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B3EE6),
                disabledBackgroundColor: const Color(0xFFCCCCCC),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _booking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Appointment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
