import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/employee_model.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String _selectedFilter = 'All';
  
  // Sample data
  final List<EmployeeModel> _dummyEmployees = [
    EmployeeModel(
      id: '1',
      employeeId: 'EMP001',
      fullName: 'John Smith',
      email: 'john.smith@example.com',
      phoneNumber: '+1234567890',
      position: 'Sales Manager',
      department: 'Sales',
      salary: 4500,
      salaryType: 'monthly',
      joinDate: DateTime(2022, 5, 15),
      status: 'active',
      managerId: 'manager123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    EmployeeModel(
      id: '2',
      employeeId: 'EMP002',
      fullName: 'Sarah Johnson',
      email: 'sarah.j@example.com',
      phoneNumber: '+1234567891',
      position: 'Cashier',
      department: 'Operations',
      salary: 15,
      salaryType: 'hourly',
      joinDate: DateTime(2023, 2, 10),
      status: 'active',
      managerId: 'manager123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    EmployeeModel(
      id: '3',
      employeeId: 'EMP003',
      fullName: 'Michael Brown',
      email: 'michael.b@example.com',
      phoneNumber: '+1234567892',
      position: 'Store Manager',
      department: 'Operations',
      salary: 5200,
      salaryType: 'monthly',
      joinDate: DateTime(2021, 8, 21),
      status: 'active',
      managerId: 'manager123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<EmployeeModel> get _filteredEmployees {
    return _dummyEmployees.where((employee) {
      // Apply search query filter
      final matchesQuery = employee.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           employee.employeeId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           employee.position.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           employee.department.toLowerCase().contains(_searchQuery.toLowerCase());
                           
      // Apply status filter
      final matchesFilter = _selectedFilter == 'All' || 
                            (_selectedFilter == 'Active' && employee.isActive) ||
                            (_selectedFilter == 'Inactive' && employee.isInactive) ||
                            (_selectedFilter == 'Terminated' && employee.isTerminated);
                            
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Active'),
                      _buildFilterChip('Inactive'),
                      _buildFilterChip('Terminated'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.sp),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return _buildEmployeeCard(employee);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppConstants.primaryColor,
        label: const Text('Add Employee'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppConstants.primaryColor.withOpacity(0.2),
        checkmarkColor: AppConstants.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      employee.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.fullName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(employee.status),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${employee.position} • ${employee.department}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppConstants.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildInfoItem(Icons.email_outlined, employee.email),
                _buildInfoItem(Icons.phone_outlined, employee.phoneNumber ?? 'Not provided'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildInfoItem(Icons.badge_outlined, 'ID: ${employee.employeeId}'),
                _buildInfoItem(Icons.calendar_today_outlined, 'Joined: ${_formatDate(employee.joinDate)}'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildInfoItem(
                  Icons.attach_money,
                  '${employee.salary} ${_formatSalaryType(employee.salaryType)}',
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showEditEmployeeDialog(employee),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () => _showEmployeeDetails(employee),
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'View Details',
                  color: Colors.green,
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(employee),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.orange;
        break;
      case 'terminated':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: AppConstants.textSecondary,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppConstants.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatSalaryType(String salaryType) {
    switch (salaryType) {
      case 'hourly':
        return '/hour';
      case 'monthly':
        return '/month';
      case 'annual':
        return '/year';
      default:
        return '';
    }
  }

  void _showAddEmployeeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Employee',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Employee management functionality will be implemented in the next phase. This is a placeholder for now.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppConstants.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditEmployeeDialog(EmployeeModel employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Employee',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Employee editing functionality will be implemented in the next phase.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppConstants.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmployeeDetails(EmployeeModel employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Employee Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Employee details view will be implemented in the next phase.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConstants.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality will be implemented in the next phase.'),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}