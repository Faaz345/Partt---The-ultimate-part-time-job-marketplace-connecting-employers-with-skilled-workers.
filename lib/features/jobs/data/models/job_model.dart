import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String managerId;
  final String managerName;
  final String managerCompany;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? latitude;
  final double? longitude;
  final double hourlyRate;
  final String workingHours;
  final DateTime startDate;
  final DateTime? endDate;
  final int maxApplicants;
  final int currentApplicants;
  final List<String> requirements;
  final List<String> benefits;
  final String status; // 'open', 'closed', 'draft'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String termsAndConditions;
  final bool isUrgent;
  final List<String> applicantIds;
  final List<String> shortlistedApplicantIds;
  final List<String> acceptedApplicantIds;

  JobModel({
    required this.id,
    required this.managerId,
    required this.managerName,
    required this.managerCompany,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.hourlyRate,
    required this.workingHours,
    required this.startDate,
    this.endDate,
    required this.maxApplicants,
    this.currentApplicants = 0,
    required this.requirements,
    required this.benefits,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.termsAndConditions,
    this.isUrgent = false,
    required this.applicantIds,
    required this.shortlistedApplicantIds,
    required this.acceptedApplicantIds,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return JobModel(
      id: doc.id,
      managerId: data['managerId'] ?? '',
      managerName: data['managerName'] ?? '',
      managerCompany: data['managerCompany'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      hourlyRate: data['hourlyRate']?.toDouble() ?? 0.0,
      workingHours: data['workingHours'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      maxApplicants: data['maxApplicants'] ?? 1,
      currentApplicants: data['currentApplicants'] ?? 0,
      requirements: List<String>.from(data['requirements'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      termsAndConditions: data['termsAndConditions'] ?? '',
      isUrgent: data['isUrgent'] ?? false,
      applicantIds: List<String>.from(data['applicantIds'] ?? []),
      shortlistedApplicantIds: List<String>.from(data['shortlistedApplicantIds'] ?? []),
      acceptedApplicantIds: List<String>.from(data['acceptedApplicantIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'managerId': managerId,
      'managerName': managerName,
      'managerCompany': managerCompany,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'hourlyRate': hourlyRate,
      'workingHours': workingHours,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'maxApplicants': maxApplicants,
      'currentApplicants': currentApplicants,
      'requirements': requirements,
      'benefits': benefits,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'termsAndConditions': termsAndConditions,
      'isUrgent': isUrgent,
      'applicantIds': applicantIds,
      'shortlistedApplicantIds': shortlistedApplicantIds,
      'acceptedApplicantIds': acceptedApplicantIds,
    };
  }

  JobModel copyWith({
    String? managerId,
    String? managerName,
    String? managerCompany,
    String? title,
    String? description,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
    double? hourlyRate,
    String? workingHours,
    DateTime? startDate,
    DateTime? endDate,
    int? maxApplicants,
    int? currentApplicants,
    List<String>? requirements,
    List<String>? benefits,
    String? status,
    DateTime? updatedAt,
    String? termsAndConditions,
    bool? isUrgent,
    List<String>? applicantIds,
    List<String>? shortlistedApplicantIds,
    List<String>? acceptedApplicantIds,
  }) {
    return JobModel(
      id: id,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      managerCompany: managerCompany ?? this.managerCompany,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      workingHours: workingHours ?? this.workingHours,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxApplicants: maxApplicants ?? this.maxApplicants,
      currentApplicants: currentApplicants ?? this.currentApplicants,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      isUrgent: isUrgent ?? this.isUrgent,
      applicantIds: applicantIds ?? this.applicantIds,
      shortlistedApplicantIds: shortlistedApplicantIds ?? this.shortlistedApplicantIds,
      acceptedApplicantIds: acceptedApplicantIds ?? this.acceptedApplicantIds,
    );
  }

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
  bool get isDraft => status == 'draft';
  bool get hasApplicationsReachedLimit => currentApplicants >= maxApplicants;
  
  String get formattedSalary => '\$${hourlyRate.toStringAsFixed(2)}/hr';
  String get daysUntilStart {
    final difference = startDate.difference(DateTime.now()).inDays;
    if (difference < 0) return 'Started';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    return 'In $difference days';
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerEmail;
  final String? workerProfileImageUrl;
  final String coverLetter;
  final String status; // 'pending', 'shortlisted', 'accepted', 'rejected'
  final DateTime appliedAt;
  final DateTime? statusUpdatedAt;
  final String? managerNotes;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.workerName,
    required this.workerEmail,
    this.workerProfileImageUrl,
    required this.coverLetter,
    required this.status,
    required this.appliedAt,
    this.statusUpdatedAt,
    this.managerNotes,
  });

  factory JobApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return JobApplication(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      workerId: data['workerId'] ?? '',
      workerName: data['workerName'] ?? '',
      workerEmail: data['workerEmail'] ?? '',
      workerProfileImageUrl: data['workerProfileImageUrl'],
      coverLetter: data['coverLetter'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statusUpdatedAt: (data['statusUpdatedAt'] as Timestamp?)?.toDate(),
      managerNotes: data['managerNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'workerId': workerId,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'workerProfileImageUrl': workerProfileImageUrl,
      'coverLetter': coverLetter,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'statusUpdatedAt': statusUpdatedAt != null ? Timestamp.fromDate(statusUpdatedAt!) : null,
      'managerNotes': managerNotes,
    };
  }

  JobApplication copyWith({
    String? status,
    DateTime? statusUpdatedAt,
    String? managerNotes,
  }) {
    return JobApplication(
      id: id,
      jobId: jobId,
      workerId: workerId,
      workerName: workerName,
      workerEmail: workerEmail,
      workerProfileImageUrl: workerProfileImageUrl,
      coverLetter: coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      managerNotes: managerNotes ?? this.managerNotes,
    );
  }

  bool get isPending => status == 'pending';
  bool get isShortlisted => status == 'shortlisted';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}