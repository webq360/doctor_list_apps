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
  final List<String> specializations;
  final int experience;
  final double fees;
  final String bio;
  final bool isApproved;
  final String location;
  final double rating;
  final int ratingCount;
  final String? imageUrl;
  final String? hospital;
  final String? hospitalId;
  final List<ScheduleModel> schedule;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.specializations = const [],
    required this.experience,
    required this.fees,
    required this.bio,
    required this.isApproved,
    this.location = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.imageUrl,
    this.hospital,
    this.hospitalId,
    this.schedule = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> j) {
    final specs = (j['specializations'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final spec = j['specialization'] as String? ?? (specs.isNotEmpty ? specs.first : '');
    final loc = j['location'];
    String locationStr = '';
    if (loc is Map) {
      final parts = [loc['division'], loc['district'], loc['upazila']].where((e) => e != null && e.toString().isNotEmpty).toList();
      locationStr = parts.join(', ');
    } else if (loc is String) {
      locationStr = loc;
    }
    final hospitalData = j['hospitalId'];
    String? hospitalName;
    String? hospitalId;
    if (hospitalData is Map) {
      hospitalName = hospitalData['name'] as String?;
      hospitalId = hospitalData['_id'] as String?;
    } else if (hospitalData is String) {
      hospitalId = hospitalData;
    }
    final scheduleList = (j['schedule'] as List?)
        ?.map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
        .toList() ?? [];
    return DoctorModel(
      id: j['_id'] ?? '',
      name: j['userId']?['name'] ?? j['name'] ?? '',
      specialization: spec,
      specializations: specs,
      experience: (j['experience'] as num?)?.toInt() ?? 0,
      fees: (j['fees'] as num?)?.toDouble() ?? 0,
      bio: j['bio'] ?? '',
      isApproved: j['isApproved'] ?? false,
      location: locationStr,
      rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
      imageUrl: j['profileImage'] ?? j['imageUrl'],
      hospital: hospitalName,
      hospitalId: hospitalId,
      schedule: scheduleList,
    );
  }
}

class ScheduleModel {
  final String day;
  final String startTime;
  final String endTime;

  const ScheduleModel({required this.day, required this.startTime, required this.endTime});

  factory ScheduleModel.fromJson(Map<String, dynamic> j) => ScheduleModel(
        day: j['day'] ?? '',
        startTime: j['startTime'] ?? '',
        endTime: j['endTime'] ?? '',
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
  final String? logoUrl;
  final String? description;
  final String? division;
  final String? district;
  final String? upazila;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.contact,
    this.distance,
    this.imageUrl,
    this.logoUrl,
    this.description,
    this.division,
    this.district,
    this.upazila,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> j) {
    final loc = j['location'];
    double lat = 0, lng = 0;
    if (loc is Map) {
      lat = (loc['lat'] as num?)?.toDouble() ?? 0;
      lng = (loc['lng'] as num?)?.toDouble() ?? 0;
    }
    return HospitalModel(
      id: j['_id'] ?? '',
      name: j['name'] ?? '',
      address: j['address'] ?? '',
      lat: lat,
      lng: lng,
      contact: j['contact'] ?? '',
      distance: j['distance'] != null ? (j['distance'] as num).toDouble() : null,
      imageUrl: j['coverImage'] ?? j['imageUrl'],
      logoUrl: j['logo'] ?? j['logoImage'] ?? j['logoUrl'],
      description: j['description'],
      division: j['division'],
      district: j['district'],
      upazila: j['upazila'],
    );
  }
}

class AppointmentModel {
  final String id;
  final String doctorName;
  final String doctorImage;
  final String date;
  final String time;
  final String status;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    this.doctorImage = '',
    required this.date,
    required this.time,
    required this.status,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> j) => AppointmentModel(
        id: j['_id'] ?? '',
        doctorName: j['doctorId']?['userId']?['name'] ?? '',
        doctorImage: j['doctorId']?['profileImage'] ?? '',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        status: j['status'] ?? 'pending',
        notes: j['notes'],
      );
}

class AmbulanceModel {
  final String id;
  final String ambulanceName;
  final String driverName;
  final String phone;
  final String vehicleNumber;
  final String ambulanceType;
  final String address;
  final String status;
  final String? driverImage;
  final String? ambulanceImage;
  final String? hospital;

  AmbulanceModel({
    required this.id,
    required this.ambulanceName,
    required this.driverName,
    required this.phone,
    required this.vehicleNumber,
    required this.ambulanceType,
    required this.address,
    required this.status,
    this.driverImage,
    this.ambulanceImage,
    this.hospital,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> j) {
    final hospitalData = j['hospitalId'];
    String? hospitalName;
    if (hospitalData is Map) hospitalName = hospitalData['name'] as String?;
    return AmbulanceModel(
      id: j['_id'] ?? '',
      ambulanceName: j['ambulanceName'] ?? '',
      driverName: j['driverName'] ?? '',
      phone: j['phone'] ?? '',
      vehicleNumber: j['vehicleNumber'] ?? '',
      ambulanceType: j['ambulanceType'] ?? 'Non-AC',
      address: j['address'] ?? '',
      status: j['status'] ?? 'available',
      driverImage: j['driverImage'],
      ambulanceImage: j['ambulanceImage'],
      hospital: hospitalName,
    );
  }
}

class HospitalServiceModel {
  final String id;
  final String name;
  final String? shortTitle;
  final String? about;
  final List<String> whatWeOffer;
  final String? iconUrl;
  final List<DoctorModel> availableDoctors;

  HospitalServiceModel({
    required this.id,
    required this.name,
    this.shortTitle,
    this.about,
    this.whatWeOffer = const [],
    this.iconUrl,
    this.availableDoctors = const [],
  });

  factory HospitalServiceModel.fromJson(Map<String, dynamic> j) {
    final doctors = (j['availableDoctors'] as List?)
        ?.map((d) => DoctorModel.fromJson(d as Map<String, dynamic>))
        .toList() ?? [];
    return HospitalServiceModel(
      id: j['_id'] ?? '',
      name: j['name'] ?? '',
      shortTitle: j['shortTitle'],
      about: j['about'],
      whatWeOffer: (j['whatWeOffer'] as List?)?.map((e) => e.toString()).toList() ?? [],
      iconUrl: j['iconUrl'],
      availableDoctors: doctors,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String targetRole;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.targetRole,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['_id'] ?? '',
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        imageUrl: j['imageUrl'],
        targetRole: j['targetRole'] ?? 'all',
        createdAt: j['createdAt'] ?? '',
      );
}

class BloodBankModel {
  final String id;
  final String name;
  final String contact;
  final String address;
  final List<String> availableGroups;
  final bool isActive;
  final String? division;
  final String? district;
  final String? upazila;

  BloodBankModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.address,
    this.availableGroups = const [],
    this.isActive = true,
    this.division,
    this.district,
    this.upazila,
  });

  factory BloodBankModel.fromJson(Map<String, dynamic> j) => BloodBankModel(
        id: j['_id'] ?? '',
        name: j['name'] ?? '',
        contact: j['contact'] ?? '',
        address: j['address'] ?? '',
        availableGroups: (j['availableGroups'] as List?)?.map((e) => e.toString()).toList() ?? [],
        isActive: j['isActive'] ?? true,
        division: j['division'],
        district: j['district'],
        upazila: j['upazila'],
      );
}

class AmbulanceRequestModel {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final String tripType;
  final String? scheduledTime;
  final String status;
  final String? notes;
  final String createdAt;

  AmbulanceRequestModel({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    required this.tripType,
    this.scheduledTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory AmbulanceRequestModel.fromJson(Map<String, dynamic> j) => AmbulanceRequestModel(
        id: j['_id'] ?? '',
        pickupAddress: j['pickupLocation']?['address'] ?? '',
        destinationAddress: j['destination']?['address'] ?? '',
        pickupLat: (j['pickupLocation']?['lat'] as num?)?.toDouble() ?? 0,
        pickupLng: (j['pickupLocation']?['lng'] as num?)?.toDouble() ?? 0,
        destinationLat: (j['destination']?['lat'] as num?)?.toDouble(),
        destinationLng: (j['destination']?['lng'] as num?)?.toDouble(),
        tripType: j['tripType'] ?? 'instant',
        scheduledTime: j['scheduledTime'],
        status: j['status'] ?? 'searching',
        notes: j['notes'],
        createdAt: j['createdAt'] ?? '',
      );
}

class BidModel {
  final String id;
  final String requestId;
  final String driverId;
  final String driverName;
  final String ambulanceName;
  final String phone;
  final double price;
  final int eta;
  final String status;

  BidModel({
    required this.id,
    required this.requestId,
    required this.driverId,
    required this.driverName,
    required this.ambulanceName,
    required this.phone,
    required this.price,
    required this.eta,
    required this.status,
  });

  factory BidModel.fromJson(Map<String, dynamic> j) => BidModel(
        id: j['_id'] ?? '',
        requestId: j['requestId'] ?? '',
        driverId: j['driverId'] ?? '',
        driverName: j['driverName'] ?? '',
        ambulanceName: j['ambulanceName'] ?? '',
        phone: j['phone'] ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        eta: (j['eta'] as num?)?.toInt() ?? 0,
        status: j['status'] ?? 'pending',
      );
}
