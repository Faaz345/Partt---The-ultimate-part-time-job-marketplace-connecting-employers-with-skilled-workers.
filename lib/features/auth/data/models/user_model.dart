import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'worker' or 'manager'
  final String? profileImageUrl;
  final String? phoneNumber;
  final String gender;
  final int age;
  final String location;
  final String education;
  final String experience;
  final List<String> skills;
  final String aboutMe;
  final BusinessDetails? businessDetails; // Only for managers
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    required this.gender,
    required this.age,
    required this.location,
    required this.education,
    required this.experience,
    required this.skills,
    required this.aboutMe,
    this.businessDetails,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.latitude,
    this.longitude,
  });

  // Convert from Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'worker',
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      location: data['location'] ?? '',
      education: data['education'] ?? '',
      experience: data['experience'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      aboutMe: data['aboutMe'] ?? '',
      businessDetails: data['businessDetails'] != null 
          ? BusinessDetails.fromMap(data['businessDetails'])
          : null,
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'age': age,
      'location': location,
      'education': education,
      'experience': experience,
      'skills': skills,
      'aboutMe': aboutMe,
      'businessDetails': businessDetails?.toMap(),
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Copy with method for updating user
  UserModel copyWith({
    String? email,
    String? fullName,
    String? role,
    String? profileImageUrl,
    String? phoneNumber,
    String? gender,
    int? age,
    String? location,
    String? education,
    String? experience,
    List<String>? skills,
    String? aboutMe,
    BusinessDetails? businessDetails,
    bool? isProfileComplete,
    DateTime? updatedAt,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      location: location ?? this.location,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      aboutMe: aboutMe ?? this.aboutMe,
      businessDetails: businessDetails ?? this.businessDetails,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  bool get isWorker => role == 'worker';
  bool get isManager => role == 'manager';
}

class BusinessDetails {
  final String businessName;
  final String businessType;
  final String businessAddress;
  final String businessDescription;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;

  BusinessDetails({
    required this.businessName,
    required this.businessType,
    required this.businessAddress,
    required this.businessDescription,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
  });

  factory BusinessDetails.fromMap(Map<String, dynamic> map) {
    return BusinessDetails(
      businessName: map['businessName'] ?? '',
      businessType: map['businessType'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      businessDescription: map['businessDescription'] ?? '',
      businessPhone: map['businessPhone'],
      businessEmail: map['businessEmail'],
      businessWebsite: map['businessWebsite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessType': businessType,
      'businessAddress': businessAddress,
      'businessDescription': businessDescription,
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'businessWebsite': businessWebsite,
    };
  }

  BusinessDetails copyWith({
    String? businessName,
    String? businessType,
    String? businessAddress,
    String? businessDescription,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
  }) {
    return BusinessDetails(
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessAddress: businessAddress ?? this.businessAddress,
      businessDescription: businessDescription ?? this.businessDescription,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessWebsite: businessWebsite ?? this.businessWebsite,
    );
  }
}