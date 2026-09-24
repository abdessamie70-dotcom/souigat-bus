import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';
import '../widgets/driver_report_dialog.dart';
import '../widgets/edit_driver_modal.dart';
import '../widgets/monthly_days_grid.dart';
import '../widgets/period_selector_bar.dart';
import '../widgets/top_kpi_card.dart';

class AttendanceWagesScreen extends StatefulWidget {
  final List<DriverModel> drivers;
  final Function(int driverIndex, int day, AttendanceStatus newStatus) onDriverDayStatusChanged;
  final Function(int driverIndex, ShiftPattern pattern) onApplyShiftPattern;
  final Function(int driverIndex, DriverModel updatedDriver)? onDriverUpdated;
  final Function(DriverModel newDriver)? onDriverAdded;

  const AttendanceWagesScreen({
    super.key,
    required this.drivers,
    required this.onDriverDayStatusChanged,
    required this.onApplyShiftPattern,
    this.onDriverUpdated,
    this.onDriverAdded,
  });

  @override
  State<AttendanceWagesScreen> createState() => _AttendanceWagesScreenState();
}

class _AttendanceWagesScreenState extends State<AttendanceWagesScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  int _selectedDriverIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  void _openAddDriverModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDriverModal(
        driver: null,
        onDriverSaved: (newDriver) {
          widget.onDriverAdded?.call(newDriver);
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
          widget.onDriverUpdated?.call(index, updatedDriver);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تعديل بيانات السائق "${updatedDriver.name}" بنجاح'),
              backgroundColor: AppColors.accentBlue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _openDriverReport(DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: DriverReportDialog(
          driver: driver,
          month: _selectedMonth,
          year: _selectedYear,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drivers.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PeriodSelectorBar(
              currentMonth: _selectedMonth,
              currentYear: _selectedYear,
              onPeriodChanged: (m, y) {
                setState(() {
                  _selectedMonth = m;
                  _selectedYear = y;
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppColors.softShadow,
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
                    child: const Icon(Icons.badge_outlined, color: AppColors.accentBlue, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'لا يوجد سائقون مسجلون لعرض كشف الحضور والأجور',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ابدأ بإضافة سائقي الحافلات لمتابعة سجلات الحضور الشهرية واحتساب الأجور',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _openAddDriverModal,
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      '+ إضافة سائق جديد',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentDriver = widget.drivers[_selectedDriverIndex.clamp(0, widget.drivers.length - 1)];

    final int workDays = currentDriver.workDaysCount;
    final int restDays = currentDriver.restDaysCount;
    final int absenceDays = currentDriver.absenceDaysCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 700;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 14,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Month and Year Selector Bar (خانة الشهر والسنة فوق)
              PeriodSelectorBar(
                currentMonth: _selectedMonth,
                currentYear: _selectedYear,
                onPeriodChanged: (m, y) {
                  setState(() {
                    _selectedMonth = m;
                    _selectedYear = y;
                  });
                },
              ),
              const SizedBox(height: 14),

              // 2. Driver Selection Chips / Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'اختيار السائق لعرض جدول الحضور والأجر:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'حافلة: ${currentDriver.assignedBus} • اليومية: ${currentDriver.dailyWage.toInt()} دج',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Print / Download Driver Statement Button
                            InkWell(
                              onTap: () => _openDriverReport(currentDriver),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDarkBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.print_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'كشف السائق',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _openEditDriverModal(_selectedDriverIndex, currentDriver),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.blueLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderBlue),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.edit_rounded, size: 11, color: AppColors.accentBlue),
                                    SizedBox(width: 3),
                                    Text(
                                      'تعديل',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accentBlue,
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
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(widget.drivers.length, (idx) {
                          final d = widget.drivers[idx];
                          final bool isSelected = idx == _selectedDriverIndex;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(d.name),
                              selected: isSelected,
                              selectedColor: AppColors.primaryDarkBlue,
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primaryDarkBlue : AppColors.borderLight,
                                ),
                              ),
                              onSelected: (_) {
                                setState(() => _selectedDriverIndex = idx);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Attendance & Wage Summary Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isTablet ? 1.45 : 1.3,
                children: [
                  TopKpiCard(
                    title: 'أيام العمل',
                    value: '$workDays',
                    unit: 'يوم',
                    subtitle: 'حاضر في الخدمة',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.accentGreen,
                    iconBgColor: AppColors.greenLight,
                    trendBadge: 'عمل 🟢',
                    isTrendPositive: true,
                  ),
                  TopKpiCard(
                    title: 'أيام الراحة',
                    value: '$restDays',
                    unit: 'أيام',
                    subtitle: 'عطل وراحات أسبوعية',
                    icon: Icons.hotel_outlined,
                    iconColor: AppColors.accentAmber,
                    iconBgColor: AppColors.amberLight,
                    trendBadge: 'راحة 🟡',
                    isTrendPositive: true,
                  ),
                  TopKpiCard(
                    title: 'أيام الغياب',
                    value: '$absenceDays',
                    unit: 'أيام',
                    subtitle: 'أيام غياب غير مدفوعة',
                    icon: Icons.cancel_outlined,
                    iconColor: AppColors.accentRed,
                    iconBgColor: AppColors.redLight,
                    trendBadge: 'غياب 🔴',
                    isTrendPositive: false,
                  ),
                  TopKpiCard(
                    title: currentDriver.loanAmount > 0 ? 'صافي أجر السائق' : 'مستحقات وأجر السائق',
                    value: currentDriver.netMonthlyWages.toInt().toString(),
                    unit: 'دج',
                    subtitle: currentDriver.loanAmount > 0
                        ? 'إجمالي: ${currentDriver.grossMonthlyWages.toInt()} دج • سلفة: -${currentDriver.loanAmount.toInt()} دج'
                        : '$workDays يوم × ${currentDriver.dailyWage.toInt()} دج',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.primaryDarkBlue,
                    iconBgColor: AppColors.surfaceLight,
                    trendBadge: currentDriver.loanAmount > 0 ? 'مخصوم سلفة 🔻' : 'حساب الشهر',
                    isTrendPositive: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Monthly Days Grid with Shift Patterns & Print Option
              MonthlyDaysGrid(
                driver: currentDriver,
                month: _selectedMonth,
                year: _selectedYear,
                onDayStatusChanged: (day, status) {
                  widget.onDriverDayStatusChanged(_selectedDriverIndex, day, status);
                },
                onApplyShiftPattern: (pattern) {
                  widget.onApplyShiftPattern(_selectedDriverIndex, pattern);
                },
                onPrintReport: () {
                  _openDriverReport(currentDriver);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
