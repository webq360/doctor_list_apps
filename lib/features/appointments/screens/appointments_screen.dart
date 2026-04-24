import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<AppointmentModel> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await ApiClient.dio.get('/appointments');
    setState(() {
      _appointments = (res.data as List).map((a) => AppointmentModel.fromJson(a)).toList();
      _loading = false;
    });
  }

  Future<void> _cancel(String id) async {
    await ApiClient.dio.patch('/appointments/$id/status', data: {'status': 'cancelled'});
    _fetch();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(child: Text('No appointments yet'))
              : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (_, i) {
                    final a = _appointments[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('Dr. ${a.doctorName}'),
                        subtitle: Text('${a.date} at ${a.time}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _statusColor(a.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(a.status, style: TextStyle(color: _statusColor(a.status), fontSize: 12)),
                            ),
                            if (a.status == 'pending')
                              TextButton(onPressed: () => _cancel(a.id), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
