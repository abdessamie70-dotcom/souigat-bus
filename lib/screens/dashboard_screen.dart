import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';
import '../widgets/driver_report_dialog.dart';
import '../widgets/edit_driver_modal.dart';
import '../widgets/new_trip_modal.dart';
import '../widgets/period_selector_bar.dart';
import '../widgets/today_driver_card.dart';
import '../widgets/today_trip_card.dart';
import '../widgets/top_kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  final List<DriverModel> drivers;
  final List<TripModel> trips;
  final Function(TripModel newTrip, int driverIndex) onTripAdded;
  final Function(int tripIndex)? onTripDeleted;
  final Function(int driverIndex, int day, AttendanceStatus newStatus) onDriverDayStatusChanged;
  final Function(int driverIndex, ShiftPattern pattern) onApplyShiftPattern;
  final Function(int driverIndex, DriverModel updatedDriver)? onDriverUpdated;
  final Function(DriverModel newDriver)? onDriverAdded;
  final Function(int driverIndex)? onDriverDeleted;

  const DashboardScreen({
    super.key,
    required this.drivers,
    required this.trips,
    required this.onTripAdded,
    this.onTripDeleted,
    required this.onDriverDayStatusChanged,
    required this.onApplyShiftPattern,
    this.onDriverUpdated,
    this.onDriverAdded,
    this.onDriverDeleted,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMonth = 9;
  int _selectedYear = 2026;
  int _selectedDay = 24;

  String _driverFilter = 'working'; // 'working', 'all', 'rest'
  String _tripFilter = 'all'; // 'all', 'في الطريق', 'مجدولة', 'مكتملة'

  void _openNewTripModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NewTripModal(
        drivers: widget.drivers,
        onTripAdded: widget.onTripAdded,
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

  void _confirmDeleteDriver(int index, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentRed),
            SizedBox(width: 8),
            Text('تأكيد حذف السائق', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف السائق "${driver.name}" من النظام؟',
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
              widget.onDriverDeleted?.call(index);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف السائق "${driver.name}" بنجاح'),
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

  void _confirmDeleteTrip(int index, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
            SizedBox(width: 8),
            Text('تأكيد حذف الرحلة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل تريد حذف رحلة "${trip.route}" المجدولة على الساعة ${trip.departureTime}؟',
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
              widget.onTripDeleted?.call(index);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف رحلة "${trip.route}" بنجاح'),
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
            child: const Text('حذف الرحلة', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
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

    // 1. Calculate Drivers metrics for today
    final int workingDriversCount = widget.drivers
        .where((d) => d.getDayStatus(_selectedDay) == AttendanceStatus.work)
        .length;
    final int restDriversCount = widget.drivers
        .where((d) => d.getDayStatus(_selectedDay) == AttendanceStatus.rest)
        .length;
    final int absenceDriversCount = widget.drivers
        .where((d) => d.getDayStatus(_selectedDay) == AttendanceStatus.absence)
        .length;

    // Filter drivers
    final filteredDrivers = widget.drivers.where((d) {
      final st = d.getDayStatus(_selectedDay);
      if (_driverFilter == 'working') return st == AttendanceStatus.work;
      if (_driverFilter == 'rest') return st == AttendanceStatus.rest;
      return true; // 'all'
    }).toList();

    // 2. Calculate Trips metrics for today
    final int tripsCount = widget.trips.length;
    int totalPassengers = 0;
    for (final t in widget.trips) {
      totalPassengers += t.passengers;
    }
    final int totalCapacity = tripsCount * 50;
    final int occupancyRate = totalCapacity > 0
        ? ((totalPassengers / totalCapacity) * 100).round()
        : 0;

    // Filter trips
    final filteredTrips = widget.trips.where((t) {
      if (_tripFilter == 'all') return true;
      return t.status == _tripFilter;
    }).toList();

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
              // 1. Month & Year Selector at the Top (خانة الشهر والسنة فوق)
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
              const SizedBox(height: 12),

              // 2. Today's Date Banner with Day Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.cardElevation,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/company_logo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, _, __) => Container(
                                color: Colors.white.withOpacity(0.15),
                                child: const Icon(
                                  Icons.directions_bus_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مؤسسة سويقات أبو طالب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اليوم: $_selectedDay سبتمبر $_selectedYear • جدول التشغيل',
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _openNewTripModal,
                      icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'برمجة رحلة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. TOP OPERATIONAL KPI CARDS ROW (لا وقود ولا إيرادات ولا صافي المؤسسة)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isTablet ? 1.45 : 1.3,
                children: [
                  // KPI 1: الرحلات المبرمجة اليوم
                  TopKpiCard(
                    title: 'الرحلات المبرمجة اليوم',
                    value: '$tripsCount',
                    unit: 'رحلة',
                    subtitle: 'رحلات نقل المسافرين',
                    icon: Icons.alt_route_rounded,
                    iconColor: AppColors.accentBlue,
                    iconBgColor: AppColors.blueLight,
                    trendBadge: 'مجدولة وجارية',
                    isTrendPositive: true,
                  ),

                  // KPI 2: السائقون العاملون اليوم
                  TopKpiCard(
                    title: 'السائقون العاملون اليوم',
                    value: '$workingDriversCount',
                    unit: 'سائق',
                    subtitle: 'حاضرون في الخدمة',
                    icon: Icons.airline_seat_recline_extra_rounded,
                    iconColor: AppColors.accentGreen,
                    iconBgColor: AppColors.greenLight,
                    trendBadge: 'عمل 🟢',
                    isTrendPositive: true,
                  ),

                  // KPI 3: سائقون في راحة أو غياب
                  TopKpiCard(
                    title: 'سائقون في راحة / غياب',
                    value: '${restDriversCount + absenceDriversCount}',
                    unit: 'سائق',
                    subtitle: '$restDriversCount راحة • $absenceDriversCount غياب',
                    icon: Icons.hotel_rounded,
                    iconColor: AppColors.accentAmber,
                    iconBgColor: AppColors.amberLight,
                    trendBadge: 'عطل ومناوبات 🟡',
                    isTrendPositive: false,
                  ),

                  // KPI 4: حجز مقاعد الحافلات الكبيرة
                  TopKpiCard(
                    title: 'حجز مقاعد الحافلات',
                    value: '$totalPassengers',
                    unit: 'مسافر',
                    subtitle: '$occupancyRate% من سعة الأسطول',
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.accentOrange,
                    iconBgColor: AppColors.orangeLight,
                    trendBadge: 'امتلاء الأسطول',
                    isTrendPositive: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ========================================================
              // SECTION 1: السائقون العاملون اليوم (WORKING DRIVERS TODAY)
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          size: 18,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'السائقون العاملون اليوم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$workingDriversCount في الخدمة',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filter Chips for Drivers
                  Row(
                    children: [
                      _buildChip(
                        label: 'العاملون ($workingDriversCount)',
                        isSelected: _driverFilter == 'working',
                        onTap: () => setState(() => _driverFilter = 'working'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'الكل (${widget.drivers.length})',
                        isSelected: _driverFilter == 'all',
                        onTap: () => setState(() => _driverFilter = 'all'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'في راحة ($restDriversCount)',
                        isSelected: _driverFilter == 'rest',
                        onTap: () => setState(() => _driverFilter = 'rest'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Driver Cards List or Empty State
              if (filteredDrivers.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlue),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.accentBlue, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.drivers.isEmpty ? 'لا يوجد سائقون مسجلون حالياً' : 'لا يوجد سائقون في هذه الفئة لهذا اليوم',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.drivers.isEmpty
                            ? 'يمكنك البدء بإضافة السائقين وتعيين حافلاتهم ومناوباتهم الشهرية'
                            : 'جرّب تغيير فلتر العرض أعلاه لعرض السائقين الآخرين',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.drivers.isEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _openAddDriverModal,
                          icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            '+ إضافة سائق جديد',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ...filteredDrivers.map((driver) {
                  final driverIdx = widget.drivers.indexOf(driver);
                  final activeTrip = widget.trips.cast<TripModel?>().firstWhere(
                    (t) => t?.driverName == driver.name,
                    orElse: () => null,
                  );

                  return TodayDriverCard(
                    driver: driver,
                    todayDay: _selectedDay,
                    activeTrip: activeTrip,
                    onStatusChanged: (newStatus) {
                      widget.onDriverDayStatusChanged(driverIdx, _selectedDay, newStatus);
                    },
                    onEditDriver: () => _openEditDriverModal(driverIdx, driver),
                    onDeleteDriver: () => _confirmDeleteDriver(driverIdx, driver),
                    onPrintReport: () => _openDriverReport(driver),
                  );
                }),

              const SizedBox(height: 24),

              // ========================================================
              // SECTION 2: الرحلات المبرمجة اليوم (TODAY'S SCHEDULED TRIPS)
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'الرحلات المبرمجة اليوم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          '$tripsCount رحلة',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filter Chips for Trips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip(
                          label: 'الكل ($tripsCount)',
                          isSelected: _tripFilter == 'all',
                          onTap: () => setState(() => _tripFilter = 'all'),
                        ),
                        const SizedBox(width: 6),
                        _buildChip(
                          label: 'في الطريق',
                          isSelected: _tripFilter == 'في الطريق',
                          onTap: () => setState(() => _tripFilter = 'في الطريق'),
                        ),
                        const SizedBox(width: 6),
                        _buildChip(
                          label: 'مجدولة',
                          isSelected: _tripFilter == 'مجدولة',
                          onTap: () => setState(() => _tripFilter = 'مجدولة'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Scheduled Trips List or Empty State
              if (filteredTrips.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderBlue),
                        ),
                        child: const Icon(Icons.alt_route_rounded, color: AppColors.accentBlue, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.trips.isEmpty ? 'لا توجد رحلات مبرمجة حالياً' : 'لا توجد رحلات مطابقة للمحدد حالياً',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.trips.isEmpty
                            ? 'يمكنك البدء ببرمجة رحلات الحافلات وتحديد المسار والسائق المكلّف'
                            : 'جرّب اختيار فلتر آخر لعرض باقي الرحلات اليومية',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.trips.isEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _openNewTripModal,
                          icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            '+ برمجة رحلة جديدة',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ...filteredTrips.map((trip) {
                  final tripIdx = widget.trips.indexOf(trip);
                  return TodayTripCard(
                    trip: trip,
                    onStatusToggle: () => _cycleTripStatus(trip),
                    onDeleteTrip: () => _confirmDeleteTrip(tripIdx, trip),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkBlue : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryDarkBlue : AppColors.borderLight,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDarkBlue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
