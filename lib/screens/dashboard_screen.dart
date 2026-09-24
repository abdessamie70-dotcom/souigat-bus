import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';
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
  final Function(int driverIndex, int day, AttendanceStatus newStatus) onDriverDayStatusChanged;
  final Function(int driverIndex, ShiftPattern pattern) onApplyShiftPattern;
  final Function(int driverIndex, DriverModel updatedDriver)? onDriverUpdated;

  const DashboardScreen({
    super.key,
    required this.drivers,
    required this.trips,
    required this.onTripAdded,
    required this.onDriverDayStatusChanged,
    required this.onApplyShiftPattern,
    this.onDriverUpdated,
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

  void _openEditDriverModal(int index, DriverModel driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDriverModal(
        driver: driver,
        onDriverUpdated: (updatedDriver) {
          widget.onDriverUpdated?.call(index, updatedDriver);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تعديل بيانات السائق "${updatedDriver.name}" بنجاح'),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _cycleTripStatus(TripModel trip) {
    setState(() {
      if (trip.status == 'مجدولة') {
        trip.status = 'جاهزة للانطلاق';
      } else if (trip.status == 'جاهزة للانطلاق') {
        trip.status = 'في الطريق';
      } else if (trip.status == 'في الطريق') {
        trip.status = 'مكتملة';
      } else {
        trip.status = 'مجدولة';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة رحلة "${trip.route}" إلى "${trip.status}"'),
        backgroundColor: AppColors.primaryDarkBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drivers.isEmpty) return const SizedBox.shrink();

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
                        backgroundColor: AppColors.accentOrange,
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

              // Driver Cards List
              if (filteredDrivers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Center(
                    child: Text(
                      'لا يوجد سائقون في هذه الفئة لهذا اليوم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...filteredDrivers.map((driver) {
                  final driverIdx = widget.drivers.indexOf(driver);
                  // Find any active trip for this driver
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
                        child: const Text(
                          'رحلات اليوم',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentOrange,
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

              // Scheduled Trips List
              if (filteredTrips.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Center(
                    child: Text(
                      'لا توجد رحلات مطابقة للمحدد حالياً',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...filteredTrips.map((trip) {
                  return TodayTripCard(
                    trip: trip,
                    onStatusToggle: () => _cycleTripStatus(trip),
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
