import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';

class TodayTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onStatusToggle;
  final VoidCallback? onDeleteTrip;

  const TodayTripCard({
    super.key,
    required this.trip,
    this.onStatusToggle,
    this.onDeleteTrip,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusColor;
    IconData statusIcon;

    if (trip.status == 'مكتملة') {
      statusBg = AppColors.greenLight;
      statusColor = AppColors.accentGreen;
      statusIcon = Icons.check_circle_rounded;
    } else if (trip.status == 'في الطريق') {
      statusBg = AppColors.blueLight;
      statusColor = AppColors.accentBlue;
      statusIcon = Icons.directions_bus_rounded;
    } else if (trip.status == 'جاهزة للانطلاق') {
      statusBg = const Color(0xFFF3E8FF);
      statusColor = const Color(0xFF9333EA);
      statusIcon = Icons.departure_board_rounded;
    } else {
      statusBg = AppColors.amberLight;
      statusColor = AppColors.accentAmber;
      statusIcon = Icons.schedule_rounded;
    }

    final double occupancy = trip.occupancyPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A152238),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row: Departure Time Badge + Route Title + Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Departure Time Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'انطلاق',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        trip.departureTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Route & Bus Model
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.route,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.blueLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bus_rounded, size: 11, color: AppColors.accentBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'حافلة: ${trip.busPlate}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'سعة 50 مقعد',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge (Interactive Click to update status)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onStatusToggle,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 13, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              trip.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (onDeleteTrip != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: onDeleteTrip,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.accentRed),
                        tooltip: 'حذف الرحلة',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.redLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            // Middle: Driver Info + Bus Plate
            Row(
              children: [
                // Driver icon & name
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'السائق المكلّف:',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        trip.driverName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bus Plate Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_bus, size: 13, color: AppColors.textPrimary),
                      const SizedBox(width: 5),
                      Text(
                        trip.busPlate,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Driver Wage for this trip (No fuel / No revenue)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'أجرة السائق',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${trip.driverWage.toInt()} دج',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom: Passenger Occupancy Progress Bar (Max 50 Seats)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.airline_seat_recline_normal_rounded,
                            size: 14,
                            color: AppColors.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'حجز المقاعد: ${trip.passengers} راكب',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'نسبة الامتلاء ${occupancy.round()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: occupancy >= 90
                              ? AppColors.accentGreen
                              : (occupancy >= 70 ? AppColors.accentOrange : AppColors.accentAmber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (trip.passengers / 50.0).clamp(0.0, 1.0),
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupancy >= 90
                            ? AppColors.accentGreen
                            : (occupancy >= 70 ? AppColors.accentOrange : AppColors.accentAmber),
                      ),
                      minHeight: 6,
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
}
