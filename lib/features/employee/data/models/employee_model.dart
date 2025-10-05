import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String employeeId; // Unique employee number/code
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String position;
  final String department;
  final String? profileImageUrl;
  final double salary;
  final String salaryType; // 'hourly', 'monthly', 'annual'
  final DateTime joinDate;
  final DateTime? terminationDate;
  final String status; // 'active', 'inactive', 'terminated'
  final String managerId; // Reference to manager who created this employee
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String> skills;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? permissions; // Custom permissions for this employee

  EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.position,
    required this.department,
    this.profileImageUrl,
    required this.salary,
    required this.salaryType,
    required this.joinDate,
    this.terminationDate,
    this.status = 'active',
    required this.managerId,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.skills = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.permissions,
  });

  // Convert from Firestore Document
  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EmployeeModel(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      position: data['position'] ?? '',
      department: data['department'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      salary: (data['salary'] ?? 0.0).toDouble(),
      salaryType: data['salaryType'] ?? 'monthly',
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      terminationDate: (data['terminationDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
      managerId: data['managerId'] ?? '',
      address: data['address'],
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
      skills: List<String>.from(data['skills'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      permissions: data['permissions'] != null 
          ? Map<String, dynamic>.from(data['permissions'])
          : null,
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'position': position,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'salary': salary,
      'salaryType': salaryType,
      'joinDate': Timestamp.fromDate(joinDate),
      'terminationDate': terminationDate != null 
          ? Timestamp.fromDate(terminationDate!)
          : null,
      'status': status,
      'managerId': managerId,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'skills': skills,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'permissions': permissions,
    };
  }

  // Copy with method for updating employee
  EmployeeModel copyWith({
    String? employeeId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? position,
    String? department,
    String? profileImageUrl,
    double? salary,
    String? salaryType,
    DateTime? joinDate,
    DateTime? terminationDate,
    String? status,
    String? managerId,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    List<String>? skills,
    String? notes,
    DateTime? updatedAt,
    Map<String, dynamic>? permissions,
  }) {
    return EmployeeModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      position: position ?? this.position,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      salary: salary ?? this.salary,
      salaryType: salaryType ?? this.salaryType,
      joinDate: joinDate ?? this.joinDate,
      terminationDate: terminationDate ?? this.terminationDate,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      skills: skills ?? this.skills,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      permissions: permissions ?? this.permissions,
    );
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isTerminated => status == 'terminated';

  // Helper methods for salary calculations
  double get hourlyRate {
    switch (salaryType) {
      case 'hourly':
        return salary;
      case 'monthly':
        return salary / (4 * 40); // Assuming 40 hours per week
      case 'annual':
        return salary / (52 * 40); // Assuming 40 hours per week, 52 weeks per year
      default:
        return 0.0;
    }
  }

  double get monthlyRate {
    switch (salaryType) {
      case 'hourly':
        return salary * 40 * 4; // Assuming 40 hours per week, 4 weeks per month
      case 'monthly':
        return salary;
      case 'annual':
        return salary / 12;
      default:
        return 0.0;
    }
  }

  double get annualRate {
    switch (salaryType) {
      case 'hourly':
        return salary * 40 * 52; // Assuming 40 hours per week, 52 weeks per year
      case 'monthly':
        return salary * 12;
      case 'annual':
        return salary;
      default:
        return 0.0;
    }
  }
}