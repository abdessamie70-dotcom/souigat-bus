import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';

class TodayDriverCard extends StatelessWidget {
  final DriverModel driver;
  final int todayDay;
  final TripModel? activeTrip;
  final Function(AttendanceStatus newStatus) onStatusChanged;
  final VoidCallback? onEditDriver;

  const TodayDriverCard({
    super.key,
    required this.driver,
    required this.todayDay,
    this.activeTrip,
    required this.onStatusChanged,
    this.onEditDriver,
  });

  @override
  Widget build(BuildContext context) {
    final status = driver.getDayStatus(todayDay);

    Color statusColor;
    Color statusBg;
    String statusTitle;

    switch (status) {
      case AttendanceStatus.work:
        statusColor = AppColors.accentGreen;
        statusBg = AppColors.greenLight;
        statusTitle = 'في الخدمة (عمل)';
        break;
      case AttendanceStatus.rest:
        statusColor = AppColors.accentAmber;
        statusBg = AppColors.amberLight;
        statusTitle = 'في راحة (عطلة)';
        break;
      case AttendanceStatus.absence:
        statusColor = AppColors.accentRed;
        statusBg = AppColors.redLight;
        statusTitle = 'غائب (غير حاضر)';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == AttendanceStatus.work ? statusColor.withOpacity(0.5) : AppColors.borderLight,
          width: status == AttendanceStatus.work ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: status == AttendanceStatus.work
                ? statusColor.withOpacity(0.08)
                : const Color(0x0A152238),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Top Row: Avatar + Name + Assigned Bus + Current Status Badge
            Row(
              children: [
                // Avatar with status ring
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Driver details
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
                              color: AppColors.surfaceLight,
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
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_rounded, size: 12, color: AppColors.accentOrange),
                          const SizedBox(width: 4),
                          Text(
                            'حافلة: ${driver.assignedBus}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge for Today
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ),

                if (onEditDriver != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onEditDriver,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit_rounded, size: 12, color: AppColors.accentOrange),
                          SizedBox(width: 4),
                          Text(
                            'تعديل',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 10),

            // Middle Row: Phone with quick call + Daily Wage + Shift Pattern title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Phone & Contact
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        size: 13,
                        color: AppColors.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driver.phone,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                // Pattern name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    driver.currentPattern.title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Daily Wage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'اليومية',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${driver.dailyWage.toInt()} دج',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // If there is an active scheduled trip for this driver today
            if (activeTrip != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_rounded, size: 14, color: AppColors.accentGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'مكلّف برحلة اليوم: ${activeTrip!.route} (${activeTrip!.departureTime})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF166534),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Bottom: Quick 3-way toggle buttons for today [ عمل | راحة | غياب ]
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: 'عمل (حاضر)',
                      icon: Icons.check_circle_rounded,
                      targetStatus: AttendanceStatus.work,
                      currentStatus: status,
                      activeColor: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildToggleButton(
                      label: 'راحة (عطلة)',
                      icon: Icons.hotel_rounded,
                      targetStatus: AttendanceStatus.rest,
                      currentStatus: status,
                      activeColor: AppColors.accentAmber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildToggleButton(
                      label: 'غياب',
                      icon: Icons.cancel_rounded,
                      targetStatus: AttendanceStatus.absence,
                      currentStatus: status,
                      activeColor: AppColors.accentRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required AttendanceStatus targetStatus,
    required AttendanceStatus currentStatus,
    required Color activeColor,
  }) {
    final bool isSelected = currentStatus == targetStatus;

    return GestureDetector(
      onTap: () => onStatusChanged(targetStatus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
