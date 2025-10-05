import 'package:cloud_firestore/cloud_firestore.dart';

class PayrollModel {
  final String id;
  final String employeeId;
  final String managerId;
  final String payPeriod; // Format: YYYY-MM (monthly) or YYYY-WW (weekly)
  final String payrollType; // 'monthly', 'weekly', 'bi-weekly'
  final DateTime periodStartDate;
  final DateTime periodEndDate;
  final double baseSalary;
  final double overtimePay;
  final double bonuses;
  final double allowances;
  final double deductions;
  final double taxes;
  final double netPay;
  final double grossPay;
  final int totalWorkDays;
  final int totalWorkHours; // in minutes
  final int overtimeHours; // in minutes
  final String status; // 'draft', 'approved', 'paid', 'cancelled'
  final DateTime? paidDate;
  final String? paymentMethod; // 'bank_transfer', 'cash', 'check'
  final String? paymentReference;
  final Map<String, dynamic>? breakdown; // Detailed breakdown of calculations
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  PayrollModel({
    required this.id,
    required this.employeeId,
    required this.managerId,
    required this.payPeriod,
    required this.payrollType,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.baseSalary,
    required this.overtimePay,
    required this.bonuses,
    required this.allowances,
    required this.deductions,
    required this.taxes,
    required this.netPay,
    required this.grossPay,
    required this.totalWorkDays,
    required this.totalWorkHours,
    required this.overtimeHours,
    this.status = 'draft',
    this.paidDate,
    this.paymentMethod,
    this.paymentReference,
    this.breakdown,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
  });

  // Convert from Firestore Document
  factory PayrollModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PayrollModel(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      managerId: data['managerId'] ?? '',
      payPeriod: data['payPeriod'] ?? '',
      payrollType: data['payrollType'] ?? 'monthly',
      periodStartDate: (data['periodStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodEndDate: (data['periodEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      baseSalary: (data['baseSalary'] ?? 0.0).toDouble(),
      overtimePay: (data['overtimePay'] ?? 0.0).toDouble(),
      bonuses: (data['bonuses'] ?? 0.0).toDouble(),
      allowances: (data['allowances'] ?? 0.0).toDouble(),
      deductions: (data['deductions'] ?? 0.0).toDouble(),
      taxes: (data['taxes'] ?? 0.0).toDouble(),
      netPay: (data['netPay'] ?? 0.0).toDouble(),
      grossPay: (data['grossPay'] ?? 0.0).toDouble(),
      totalWorkDays: data['totalWorkDays'] ?? 0,
      totalWorkHours: data['totalWorkHours'] ?? 0,
      overtimeHours: data['overtimeHours'] ?? 0,
      status: data['status'] ?? 'draft',
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      paymentMethod: data['paymentMethod'],
      paymentReference: data['paymentReference'],
      breakdown: data['breakdown'] != null 
          ? Map<String, dynamic>.from(data['breakdown'])
          : null,
      notes: data['notes'],
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
      'payPeriod': payPeriod,
      'payrollType': payrollType,
      'periodStartDate': Timestamp.fromDate(periodStartDate),
      'periodEndDate': Timestamp.fromDate(periodEndDate),
      'baseSalary': baseSalary,
      'overtimePay': overtimePay,
      'bonuses': bonuses,
      'allowances': allowances,
      'deductions': deductions,
      'taxes': taxes,
      'netPay': netPay,
      'grossPay': grossPay,
      'totalWorkDays': totalWorkDays,
      'totalWorkHours': totalWorkHours,
      'overtimeHours': overtimeHours,
      'status': status,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'breakdown': breakdown,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  // Copy with method
  PayrollModel copyWith({
    String? employeeId,
    String? managerId,
    String? payPeriod,
    String? payrollType,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    double? baseSalary,
    double? overtimePay,
    double? bonuses,
    double? allowances,
    double? deductions,
    double? taxes,
    double? netPay,
    double? grossPay,
    int? totalWorkDays,
    int? totalWorkHours,
    int? overtimeHours,
    String? status,
    DateTime? paidDate,
    String? paymentMethod,
    String? paymentReference,
    Map<String, dynamic>? breakdown,
    String? notes,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return PayrollModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      payPeriod: payPeriod ?? this.payPeriod,
      payrollType: payrollType ?? this.payrollType,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      baseSalary: baseSalary ?? this.baseSalary,
      overtimePay: overtimePay ?? this.overtimePay,
      bonuses: bonuses ?? this.bonuses,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      taxes: taxes ?? this.taxes,
      netPay: netPay ?? this.netPay,
      grossPay: grossPay ?? this.grossPay,
      totalWorkDays: totalWorkDays ?? this.totalWorkDays,
      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      breakdown: breakdown ?? this.breakdown,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  // Helper getters
  bool get isDraft => status == 'draft';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isCancelled => status == 'cancelled';

  // Format work hours as string
  String get totalWorkHoursFormatted {
    final hours = totalWorkHours ~/ 60;
    final minutes = totalWorkHours % 60;
    return '${hours}h ${minutes}m';
  }

  String get overtimeHoursFormatted {
    final hours = overtimeHours ~/ 60;
    final minutes = overtimeHours % 60;
    return '${hours}h ${minutes}m';
  }

  // Helper method to calculate payroll automatically
  static PayrollModel calculatePayroll({
    required String employeeId,
    required String managerId,
    required String payPeriod,
    required String payrollType,
    required DateTime periodStartDate,
    required DateTime periodEndDate,
    required double employeeBaseSalary,
    required String employeeSalaryType,
    required int totalWorkDays,
    required int totalWorkHours, // in minutes
    required int overtimeHours, // in minutes
    double bonuses = 0.0,
    double allowances = 0.0,
    double deductions = 0.0,
    double taxRate = 0.15, // 15% default tax rate
    double overtimeRate = 1.5, // 1.5x overtime rate
  }) {
    // Calculate base salary for the period
    double baseSalary = 0.0;
    
    switch (employeeSalaryType) {
      case 'hourly':
        baseSalary = employeeBaseSalary * (totalWorkHours / 60.0);
        break;
      case 'monthly':
        baseSalary = employeeBaseSalary;
        break;
      case 'annual':
        final daysInYear = 365;
        final workDaysInPeriod = periodEndDate.difference(periodStartDate).inDays + 1;
        baseSalary = (employeeBaseSalary / daysInYear) * workDaysInPeriod;
        break;
    }

    // Calculate overtime pay
    double overtimePay = 0.0;
    if (overtimeHours > 0) {
      double hourlyRate = employeeBaseSalary;
      if (employeeSalaryType == 'monthly') {
        hourlyRate = employeeBaseSalary / (4 * 40); // Assuming 40 hours per week
      } else if (employeeSalaryType == 'annual') {
        hourlyRate = employeeBaseSalary / (52 * 40); // Assuming 40 hours per week, 52 weeks per year
      }
      overtimePay = hourlyRate * overtimeRate * (overtimeHours / 60.0);
    }

    // Calculate gross pay
    final grossPay = baseSalary + overtimePay + bonuses + allowances;

    // Calculate taxes
    final taxes = grossPay * taxRate;

    // Calculate net pay
    final netPay = grossPay - deductions - taxes;

    // Create breakdown
    final breakdown = {
      'baseSalary': baseSalary,
      'overtimePay': overtimePay,
      'bonuses': bonuses,
      'allowances': allowances,
      'grossPay': grossPay,
      'deductions': deductions,
      'taxes': taxes,
      'taxRate': taxRate,
      'overtimeRate': overtimeRate,
      'netPay': netPay,
    };

    return PayrollModel(
      id: '', // Will be set by Firestore
      employeeId: employeeId,
      managerId: managerId,
      payPeriod: payPeriod,
      payrollType: payrollType,
      periodStartDate: periodStartDate,
      periodEndDate: periodEndDate,
      baseSalary: baseSalary,
      overtimePay: overtimePay,
      bonuses: bonuses,
      allowances: allowances,
      deductions: deductions,
      taxes: taxes,
      netPay: netPay,
      grossPay: grossPay,
      totalWorkDays: totalWorkDays,
      totalWorkHours: totalWorkHours,
      overtimeHours: overtimeHours,
      breakdown: breakdown,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Payroll summary for reporting
class PayrollSummary {
  final String period; // YYYY-MM
  final int totalEmployees;
  final double totalGrossPay;
  final double totalNetPay;
  final double totalTaxes;
  final double totalDeductions;
  final double totalBonuses;
  final double totalAllowances;
  final double totalOvertimePay;
  final int totalPaidPayrolls;
  final int totalPendingPayrolls;

  PayrollSummary({
    required this.period,
    required this.totalEmployees,
    required this.totalGrossPay,
    required this.totalNetPay,
    required this.totalTaxes,
    required this.totalDeductions,
    required this.totalBonuses,
    required this.totalAllowances,
    required this.totalOvertimePay,
    required this.totalPaidPayrolls,
    required this.totalPendingPayrolls,
  });

  factory PayrollSummary.fromPayrollList(String period, List<PayrollModel> payrolls) {
    final totalEmployees = payrolls.length;
    final totalGrossPay = payrolls.fold(0.0, (sum, p) => sum + p.grossPay);
    final totalNetPay = payrolls.fold(0.0, (sum, p) => sum + p.netPay);
    final totalTaxes = payrolls.fold(0.0, (sum, p) => sum + p.taxes);
    final totalDeductions = payrolls.fold(0.0, (sum, p) => sum + p.deductions);
    final totalBonuses = payrolls.fold(0.0, (sum, p) => sum + p.bonuses);
    final totalAllowances = payrolls.fold(0.0, (sum, p) => sum + p.allowances);
    final totalOvertimePay = payrolls.fold(0.0, (sum, p) => sum + p.overtimePay);
    final totalPaidPayrolls = payrolls.where((p) => p.isPaid).length;
    final totalPendingPayrolls = payrolls.where((p) => !p.isPaid).length;

    return PayrollSummary(
      period: period,
      totalEmployees: totalEmployees,
      totalGrossPay: totalGrossPay,
      totalNetPay: totalNetPay,
      totalTaxes: totalTaxes,
      totalDeductions: totalDeductions,
      totalBonuses: totalBonuses,
      totalAllowances: totalAllowances,
      totalOvertimePay: totalOvertimePay,
      totalPaidPayrolls: totalPaidPayrolls,
      totalPendingPayrolls: totalPendingPayrolls,
    );
  }
}