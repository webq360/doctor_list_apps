import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/models.dart';
import 'core/api/api_client.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/screens/profile_edit_screen.dart';
import 'features/doctors/screens/doctors_screen.dart';
import 'features/doctors/screens/doctor_detail_screen.dart';
import 'features/appointments/screens/appointments_screen.dart';
import 'features/ambulance/screens/ambulance_screen.dart';
import 'features/hospitals/screens/hospitals_screen.dart';
import 'features/notifications/screens/notification_screen.dart';
import 'shared/banner_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(onTabChange: goToTab),
      const HospitalsScreen(),
      const DoctorsScreen(),
      const AmbulanceScreen(),
      const MenuPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Menu Page ──
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiClient.dio.get('/users/me');
      if (mounted) {
        context.read<AuthProvider>().user = UserModel.fromJson(res.data);
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';
    final imageUrl = user?.imageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4158F5), Color(0xFF2B3EE6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ClipOval(
                              child: imageUrl != null
                                  ? Image.network(imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person, color: Colors.white, size: 36))
                                  : const Icon(Icons.person, color: Colors.white, size: 36),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                if (email.isNotEmpty)
                                  Text(email,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                                if (phone.isNotEmpty)
                                  Text(phone,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 4),
                _MenuSection(
                  title: 'My Activity',
                  items: [
                    _MenuItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'My Appointments',
                      color: const Color(0xFF2B3EE6),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      color: const Color(0xFFFF9500),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  title: 'Services',
                  items: [
                    _MenuItem(
                      icon: Icons.local_hospital_outlined,
                      label: 'Hospitals',
                      color: const Color(0xFF34C759),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const HospitalsScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.medical_services_outlined,
                      label: 'Doctors',
                      color: const Color(0xFF5856D6),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const DoctorsScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.airport_shuttle_outlined,
                      label: 'Ambulance',
                      color: const Color(0xFFFF3B30),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AmbulanceScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: Colors.red,
                      onTap: _logout,
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  items[i],
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDestructive ? Colors.red.withOpacity(0.4) : const Color(0xFFCCCCCC),
                size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ──
class _BottomNav extends StatelessWidget {
  final int index;
  final void Function(int) onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_hospital_outlined, 'Hospital'),
      (Icons.medical_services_outlined, 'Doctor'),
      (Icons.airport_shuttle_outlined, 'Ambulance'),
      (Icons.menu_rounded, 'Menu'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1,
                          size: 22,
                          color: selected
                              ? const Color(0xFF2B3EE6)
                              : const Color(0xFFAAAAAA)),
                      const SizedBox(height: 3),
                      Text(items[i].$2,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? const Color(0xFF2B3EE6)
                                : const Color(0xFFAAAAAA),
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Page ──
class _HomePage extends StatelessWidget {
  final void Function(int) onTabChange;
  const _HomePage({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 20),
          const _FindDoctorButton(),
          const SizedBox(height: 20),
          _AmbulanceGrid(),
          const SizedBox(height: 20),
          _SectionTitle(
            title: 'Top Doctor Near you',
            actionLabel: 'More',
            onTap: () => onTabChange(2),
          ),
          const SizedBox(height: 10),
          const _TopDoctorsList(),
          const SizedBox(height: 20),

          // ── Physiotherapy Center ──
          const _SectionTitle(title: 'Physiotherapy Center', actionLabel: 'View All'),
          const SizedBox(height: 10),
          const _ServiceList(
            items: [
              ('Rehab Center', 'Ora; Health Specialty', false),
              ('Agrani Sani', 'Ora; Health Specialty', false),
              ('Agrani Sani', 'Ora; Health Specialty', false),
            ],
            isAmbulance: false,
          ),
          const SizedBox(height: 20),

          // ── Top Rate Ambulance ──
          const _SectionTitle(title: 'Top Rate Ambulance', actionLabel: 'View All'),
          const SizedBox(height: 10),
          const _ServiceList(
            items: [
              ('Mohsin', 'Ora; Health Specialty', true),
              ('Sani', 'Ora; Health Specialty', true),
              ('Nazmul', 'Ora; Health Specialty', true),
            ],
            isAmbulance: true,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4158F5), Color(0xFF2B3EE6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: CustomPaint(painter: _StripePainter()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: avatar + greeting + notification
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.white24,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Hi, Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen()),
                        ),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Banner inside white card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: const BannerSlider(),
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

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.55, 0)
        ..lineTo(size.width * 0.75, 0)
        ..lineTo(size.width * 0.45, size.height)
        ..lineTo(size.width * 0.25, size.height)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.72, 0)
        ..lineTo(size.width * 0.85, 0)
        ..lineTo(size.width * 0.62, size.height)
        ..lineTo(size.width * 0.49, size.height)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Find Doctor Button ──
class _FindDoctorButton extends StatelessWidget {
  const _FindDoctorButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final state = context.findAncestorStateOfType<_HomeScreenState>();
          state?.goToTab(2);
        },
        child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/find_doctor_icon.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find Doctor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── Section Title ──
class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onTap;
  const _SectionTitle({required this.title, required this.actionLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          if (actionLabel.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Text(actionLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2B3EE6),
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}

// ── Ambulance Grid ──
class _AmbulanceGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (_, i) => _AmbulanceCard(),
      ),
    );
  }
}

class _AmbulanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ambulance.png',
            width: 48,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.airport_shuttle,
              color: Color(0xFFFF6B35),
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ambulance Hire',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Doctors List ──
class _TopDoctorsList extends StatelessWidget {
  const _TopDoctorsList();

  static final _doctors = [
    DoctorModel(id: '1', name: 'Dr. Arif Hossain', specialization: 'Cardiologist', experience: 12, fees: 800, bio: 'Specialist in heart diseases.', isApproved: true, location: 'Dhaka', rating: 4.8, ratingCount: 124, hospital: 'Dhaka Medical College Hospital'),
    DoctorModel(id: '2', name: 'Dr. Nusrat Jahan', specialization: 'Gynecologist', experience: 8, fees: 600, bio: 'Expert in women health and maternity care.', isApproved: true, location: 'Chittagong', rating: 4.6, ratingCount: 98, hospital: 'Popular Medical Centre'),
    DoctorModel(id: '3', name: 'Dr. Rakibul Islam', specialization: 'Neurologist', experience: 15, fees: 1000, bio: 'Senior neurologist with expertise in stroke.', isApproved: true, location: 'Dhaka', rating: 4.9, ratingCount: 210, hospital: 'National Institute of Neurosciences'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _doctors.map((d) => _DoctorTile(
        doctor: d,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: d))),
      )).toList(),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  const _DoctorTile({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE0CC),
              border: Border.all(color: const Color(0xFFFFB347), width: 1.5),
            ),
            child: const Icon(Icons.person, color: Color(0xFFFF8C42), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Text(doctor.specialization,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                if (doctor.hospital != null)
                  Text(doctor.hospital!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2B3EE6))),
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

// ── Service List (Physiotherapy + Ambulance) ──
class _ServiceList extends StatelessWidget {
  final List<(String, String, bool)> items;
  final bool isAmbulance;
  const _ServiceList({required this.items, required this.isAmbulance});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => _ServiceTile(
                name: item.$1,
                specialty: item.$2,
                isAmbulance: isAmbulance,
              ))
          .toList(),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String name;
  final String specialty;
  final bool isAmbulance;
  const _ServiceTile(
      {required this.name,
      required this.specialty,
      required this.isAmbulance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              isAmbulance
                  ? 'assets/images/ambulance.png'
                  : 'assets/images/hospital.png',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isAmbulance
                      ? const Color(0xFFFFEEE8)
                      : const Color(0xFFE8F5E9),
                ),
                child: Icon(
                  isAmbulance ? Icons.airport_shuttle : Icons.local_hospital,
                  color: isAmbulance
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF4CAF50),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                Text(specialty,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF888888))),
                const SizedBox(height: 4),
                // Star rating (empty)
                Row(
                  children: List.generate(
                    5,
                    (i) => const Icon(Icons.star_border,
                        size: 12, color: Color(0xFFCCCCCC)),
                  ),
                ),
              ],
            ),
          ),
          // Call button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone, size: 13),
            label: const Text('Call',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B3EE6),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
