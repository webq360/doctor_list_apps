import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _notifications = [
    (Icons.calendar_today_outlined, 'Appointment Confirmed', 'Your appointment with Dr. Mosabber is confirmed for 20 Sep at 12:30pm', '2 min ago'),
    (Icons.local_hospital_outlined, 'New Doctor Available', 'Dr. Rahman (Cardiologist) is now available for booking', '1 hour ago'),
    (Icons.airport_shuttle_outlined, 'Ambulance Booked', 'Your ambulance request has been accepted', '3 hours ago'),
    (Icons.check_circle_outline, 'Appointment Completed', 'Your appointment with Dr. Sani is marked as completed', 'Yesterday'),
    (Icons.info_outline, 'Profile Update', 'Please complete your profile for better service', '2 days ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B3EE6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Clear all', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 12),
                  Text('No notifications', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(n.$1, color: const Color(0xFF2B3EE6), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.$2,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 4),
                            Text(n.$3,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF888888), height: 1.4)),
                            const SizedBox(height: 6),
                            Text(n.$4,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF2B3EE6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
