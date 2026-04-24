class UserModel {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String role;
  final String? imageUrl;

  UserModel({required this.id, required this.name, this.email, required this.phone, required this.role, this.imageUrl});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] ?? j['_id'],
        name: j['name'] ?? '',
        email: j['email'],
        phone: j['phone'] ?? '',
        role: j['role'] ?? 'patient',
        imageUrl: j['imageUrl'],
      );
}

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final double fees;
  final String bio;
  final bool isApproved;
  final String location;
  final double rating;
  final int ratingCount;
  final String? imageUrl;
  final String? hospital;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.fees,
    required this.bio,
    required this.isApproved,
    this.location = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.imageUrl,
    this.hospital,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> j) => DoctorModel(
        id: j['_id'],
        name: j['userId']?['name'] ?? '',
        specialization: j['specialization'],
        experience: j['experience'],
        fees: (j['fees'] as num).toDouble(),
        bio: j['bio'] ?? '',
        isApproved: j['isApproved'] ?? false,
        location: j['location'] ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: j['ratingCount'] ?? 0,
        imageUrl: j['imageUrl'],
        hospital: j['hospital'],
      );
}

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String contact;
  final double? distance;
  final String? imageUrl;
  final String? description;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.contact,
    this.distance,
    this.imageUrl,
    this.description,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> j) => HospitalModel(
        id: j['_id'],
        name: j['name'],
        address: j['address'],
        lat: (j['location']['lat'] as num).toDouble(),
        lng: (j['location']['lng'] as num).toDouble(),
        contact: j['contact'],
        distance: j['distance'] != null ? (j['distance'] as num).toDouble() : null,
        imageUrl: j['imageUrl'],
        description: j['description'],
      );
}

class AppointmentModel {
  final String id;
  final String doctorName;
  final String date;
  final String time;
  final String status;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> j) => AppointmentModel(
        id: j['_id'],
        doctorName: j['doctorId']?['userId']?['name'] ?? '',
        date: j['date'],
        time: j['time'],
        status: j['status'],
      );
}
