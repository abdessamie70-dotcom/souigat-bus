import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';
import 'day_attendance_card.dart';

class MonthlyDaysGrid extends StatelessWidget {
  final DriverModel driver;
  final int month;
  final int year;
  final Function(int day, AttendanceStatus status) onDayStatusChanged;
  final Function(ShiftPattern pattern) onApplyShiftPattern;
  final VoidCallback onPrintReport;

  const MonthlyDaysGrid({
    super.key,
    required this.driver,
    required this.month,
    required this.year,
    required this.onDayStatusChanged,
    required this.onApplyShiftPattern,
    required this.onPrintReport,
  });

  static const List<String> weekdayArabic = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  String _getDayName(int day) {
    final dt = DateTime(year, month, day);
    return weekdayArabic[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06152238),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Print Button
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
                      Icons.calendar_view_month_rounded,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جدول أيام الشهر (${driver.name})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'عرض جميع الأيام ($daysInMonth يوم) مع خيار: عمل / راحة / غياب',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Prominent Print Report Button (طباعة وتحميل كشف السائق)
              ElevatedButton.icon(
                onPressed: onPrintReport,
                icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'كشف السائق (طباعة / تحميل)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Shift Patterns Bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'نظام وجدول مناوبة السائق:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'تطبيق تلقائي على كامل أيام الشهر ⚡',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3 Shift Pattern Buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isNarrow = constraints.maxWidth < 450;
                    return isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPatternButton(
                                pattern: ShiftPattern.dayByDay,
                                label: 'عمل يوم بيوم',
                                icon: Icons.repeat_rounded,
                              ),
                              const SizedBox(height: 6),
                              _buildPatternButton(
                                pattern: ShiftPattern.oneWorkOneRest,
                                label: 'عمل يوم وراحة يوم',
                                icon: Icons.cached_rounded,
                              ),
                              const SizedBox(height: 6),
                              _buildPatternButton(
                                pattern: ShiftPattern.oneWorkTwoRest,
                                label: 'عمل يوم وراحة يومان',
                                icon: Icons.timelapse_rounded,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildPatternButton(
                                  pattern: ShiftPattern.dayByDay,
                                  label: 'عمل يوم بيوم',
                                  icon: Icons.repeat_rounded,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildPatternButton(
                                  pattern: ShiftPattern.oneWorkOneRest,
                                  label: 'عمل يوم وراحة يوم',
                                  icon: Icons.cached_rounded,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildPatternButton(
                                  pattern: ShiftPattern.oneWorkTwoRest,
                                  label: 'عمل يوم وراحة يومان',
                                  icon: Icons.timelapse_rounded,
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Grid of All Days in Month (1 to 30/31)
          LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.55,
                ),
                itemBuilder: (context, index) {
                  final int day = index + 1;
                  final String dayName = _getDayName(day);
                  final AttendanceStatus status =
                      driver.monthlyAttendance[day] ?? AttendanceStatus.work;

                  return DayAttendanceCard(
                    dayNumber: day,
                    dayName: dayName,
                    currentStatus: status,
                    onStatusSelected: (newStatus) {
                      onDayStatusChanged(day, newStatus);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatternButton({
    required ShiftPattern pattern,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = driver.currentPattern == pattern;
    return InkWell(
      onTap: () => onApplyShiftPattern(pattern),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryDarkBlue : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDarkBlue.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.accentOrange : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
