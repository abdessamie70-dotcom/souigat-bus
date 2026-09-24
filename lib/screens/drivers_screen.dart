import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';
import '../widgets/driver_report_dialog.dart';
import '../widgets/edit_driver_modal.dart';

class DriversScreen extends StatefulWidget {
  final List<DriverModel> drivers;
  final Function(int index, AttendanceStatus newStatus)? onStatusChanged;
  final Function(int index, DriverModel updatedDriver) onDriverUpdated;
  final Function(DriverModel newDriver)? onDriverAdded;
  final Function(int index)? onDriverDeleted;

  const DriversScreen({
    super.key,
    required this.drivers,
    this.onStatusChanged,
    required this.onDriverUpdated,
    this.onDriverAdded,
    this.onDriverDeleted,
  });

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  String _searchQuery = '';
  final String _filterPattern = 'all';

  void _openDriverReport(DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: DriverReportDialog(
          driver: driver,
          month: DateTime.now().month,
          year: DateTime.now().year,
        ),
      ),
    );
  }

  void _openAddDriverModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDriverModal(
        driver: null, // Add mode
        onDriverSaved: (newDriver) {
          if (widget.onDriverAdded != null) {
            widget.onDriverAdded!(newDriver);
          } else {
            widget.drivers.add(newDriver);
          }
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تمت إضافة السائق "${newDriver.name}" بنجاح'),
              backgroundColor: AppColors.accentBlue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _openEditDriverModal(int index, DriverModel driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDriverModal(
        driver: driver,
        onDriverSaved: (updatedDriver) {
          widget.onDriverUpdated(index, updatedDriver);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث بيانات السائق "${updatedDriver.name}" بنجاح'),
              backgroundColor: AppColors.accentBlue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteDriver(int index, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentRed),
            SizedBox(width: 8),
            Text(
              'تأكيد حذف السائق',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف السائق "${driver.name}" نهائياً من سجلات المؤسسة؟',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.onDriverDeleted != null) {
                widget.onDriverDeleted!(index);
              } else {
                widget.drivers.removeAt(index);
              }
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف السائق "${driver.name}" من النظام'),
                  backgroundColor: AppColors.accentRed,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('نعم، حذف', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrivers = widget.drivers.where((d) {
      final matchesSearch = d.name.contains(_searchQuery) ||
          d.phone.contains(_searchQuery) ||
          d.assignedBus.contains(_searchQuery);

      if (_filterPattern == 'all') return matchesSearch;
      return matchesSearch && d.currentPattern.shortCode == _filterPattern;
    }).toList();

    int workingCount = 0;
    int restCount = 0;
    for (final d in widget.drivers) {
      if (d.getDayStatus(DateTime.now().day) == AttendanceStatus.work) {
        workingCount++;
      } else {
        restCount++;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'إدارة السائقين والأسطول',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          ElevatedButton.icon(
            onPressed: _openAddDriverModal,
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            label: const Text(
              'إضافة سائق',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Summary Card (White & Royal Blue)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderBlue, width: 1.2),
                boxShadow: AppColors.cardElevation,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.blueLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderBlue),
                            ),
                            child: const Center(
                              child: Icon(Icons.badge_rounded, color: AppColors.accentBlue, size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'سجل سائقي مؤسسة سويقات',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${widget.drivers.length} سائقين مسجلين في الخدمة',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _openAddDriverModal,
                        icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          '+ جديد',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'العاملون اليوم',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$workingCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.amberLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'في راحة / غياب',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.amberDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$restCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accentAmber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إجمالي الأسطول',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.drivers.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppColors.softShadow,
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم السائق، الحافلة، أو الهاتف...',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.accentBlue, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Drivers List or Clean Empty State
            if (filteredDrivers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderBlue),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline_rounded, color: AppColors.accentBlue, size: 30),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'لا يوجد سائقون مسجلون حالياً',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'يمكنك البدء بإضافة سائقي الحافلات وتعيين حافلاتهم ومناوباتهم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _openAddDriverModal,
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        '+ إضافة أول سائق للمؤسسة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDrivers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final driver = filteredDrivers[index];
                  final originalIndex = widget.drivers.indexOf(driver);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top: Avatar + Name + Bus + Actions (Edit & Delete)
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  driver.name.isNotEmpty
                                      ? driver.name.split(' ').map((n) => n[0]).take(2).join('.')
                                      : 'س',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name & Bus
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          driver.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.blueLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          driver.currentPattern.shortCode,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accentBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'حافلة: ${driver.assignedBus}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // STATEMENT BUTTON (كشف السائق - طباعة وتحميل)
                            ElevatedButton.icon(
                              onPressed: () => _openDriverReport(driver),
                              icon: const Icon(Icons.print_rounded, size: 13, color: Colors.white),
                              label: const Text(
                                'كشف السائق',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDarkBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // EDIT BUTTON (تعديل)
                            ElevatedButton.icon(
                              onPressed: () => _openEditDriverModal(originalIndex, driver),
                              icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                              label: const Text(
                                'تعديل',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // DELETE BUTTON (حذف السائق)
                            IconButton(
                              onPressed: () => _confirmDeleteDriver(originalIndex, driver),
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                              tooltip: 'حذف السائق',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.redLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: 10),

                        // Details Row: Phone, License, Daily Wage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Phone
                            Row(
                              children: [
                                const Icon(Icons.phone_rounded, size: 14, color: AppColors.accentGreen),
                                const SizedBox(width: 5),
                                Text(
                                  driver.phone,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),

                            // License
                            Text(
                              driver.licenseType,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            // Daily Wage
                            Text(
                              '${driver.dailyWage.toInt()} دج/يوم',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
