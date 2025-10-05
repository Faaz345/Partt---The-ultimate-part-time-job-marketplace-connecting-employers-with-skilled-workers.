import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String employeeId;
  final String managerId;
  final DateTime date; // Date of attendance (date only, no time)
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'present', 'absent', 'late', 'half_day', 'on_leave'
  final String? checkInLocation;
  final String? checkOutLocation;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final int? workHours; // Total work hours in minutes
  final int? breakTime; // Break time in minutes
  final String? notes;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy; // Manager who approved the attendance
  final DateTime? approvedAt;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.managerId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.workHours,
    this.breakTime,
    this.notes,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
  });

  // Convert from Firestore Document
  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AttendanceModel(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      managerId: data['managerId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'absent',
      checkInLocation: data['checkInLocation'],
      checkOutLocation: data['checkOutLocation'],
      checkInLatitude: data['checkInLatitude']?.toDouble(),
      checkInLongitude: data['checkInLongitude']?.toDouble(),
      checkOutLatitude: data['checkOutLatitude']?.toDouble(),
      checkOutLongitude: data['checkOutLongitude']?.toDouble(),
      workHours: data['workHours']?.toInt(),
      breakTime: data['breakTime']?.toInt(),
      notes: data['notes'],
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedBy: data['approvedBy'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'managerId': managerId,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'status': status,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'workHours': workHours,
      'breakTime': breakTime,
      'notes': notes,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // Copy with method
  AttendanceModel copyWith({
    String? employeeId,
    String? managerId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? checkInLocation,
    String? checkOutLocation,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    int? workHours,
    int? breakTime,
    String? notes,
    bool? isApproved,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return AttendanceModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      workHours: workHours ?? this.workHours,
      breakTime: breakTime ?? this.breakTime,
      notes: notes ?? this.notes,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  // Helper getters
  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isHalfDay => status == 'half_day';
  bool get isOnLeave => status == 'on_leave';

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
  bool get isComplete => hasCheckedIn && hasCheckedOut;

  // Calculate work duration in minutes
  int? get workDurationMinutes {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!).inMinutes - (breakTime ?? 0);
    }
    return null;
  }

  // Calculate work duration in hours (decimal)
  double? get workDurationHours {
    final minutes = workDurationMinutes;
    return minutes != null ? minutes / 60.0 : null;
  }

  // Format work duration as string (HH:MM)
  String get workDurationFormatted {
    final minutes = workDurationMinutes;
    if (minutes == null) return '--:--';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  // Check if employee is late (assuming 9 AM is standard check-in time)
  bool isLateForStandardTime({DateTime? standardCheckIn}) {
    if (checkInTime == null) return false;
    
    final standard = standardCheckIn ?? DateTime(
      checkInTime!.year,
      checkInTime!.month,
      checkInTime!.day,
      9, // 9 AM
    );
    
    return checkInTime!.isAfter(standard);
  }

  // Calculate overtime in minutes
  int calculateOvertimeMinutes({int standardWorkMinutes = 480}) { // 8 hours = 480 minutes
    final worked = workDurationMinutes ?? 0;
    return worked > standardWorkMinutes ? worked - standardWorkMinutes : 0;
  }
}

// Attendance summary model for reports
class AttendanceSummary {
  final String employeeId;
  final String month; // Format: YYYY-MM
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalHalfDay;
  final int totalOnLeave;
  final int totalWorkDays;
  final int totalWorkMinutes;
  final int totalOvertimeMinutes;
  final double attendancePercentage;

  AttendanceSummary({
    required this.employeeId,
    required this.month,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
    required this.totalHalfDay,
    required this.totalOnLeave,
    required this.totalWorkDays,
    required this.totalWorkMinutes,
    required this.totalOvertimeMinutes,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromAttendanceList(String employeeId, String month, List<AttendanceModel> attendances) {
    final totalPresent = attendances.where((a) => a.isPresent).length;
    final totalAbsent = attendances.where((a) => a.isAbsent).length;
    final totalLate = attendances.where((a) => a.isLate).length;
    final totalHalfDay = attendances.where((a) => a.isHalfDay).length;
    final totalOnLeave = attendances.where((a) => a.isOnLeave).length;
    final totalWorkDays = attendances.length;
    
    final totalWorkMinutes = attendances
        .map((a) => a.workDurationMinutes ?? 0)
        .reduce((a, b) => a + b);
    
    final totalOvertimeMinutes = attendances
        .map((a) => a.calculateOvertimeMinutes())
        .reduce((a, b) => a + b);
    
    final attendancePercentage = totalWorkDays > 0 
        ? (totalPresent / totalWorkDays) * 100 
        : 0.0;

    return AttendanceSummary(
      employeeId: employeeId,
      month: month,
      totalPresent: totalPresent,
      totalAbsent: totalAbsent,
      totalLate: totalLate,
      totalHalfDay: totalHalfDay,
      totalOnLeave: totalOnLeave,
      totalWorkDays: totalWorkDays,
      totalWorkMinutes: totalWorkMinutes,
      totalOvertimeMinutes: totalOvertimeMinutes,
      attendancePercentage: attendancePercentage,
    );
  }

  String get totalWorkHours => '${(totalWorkMinutes / 60).toStringAsFixed(1)}h';
  String get totalOvertimeHours => '${(totalOvertimeMinutes / 60).toStringAsFixed(1)}h';
}