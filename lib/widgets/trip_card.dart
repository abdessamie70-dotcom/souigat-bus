import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onDeleteTrip;

  const TripCard({super.key, required this.trip, this.onDeleteTrip});

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusColor;
    if (trip.status == 'مكتملة') {
      statusBg = AppColors.greenLight;
      statusColor = AppColors.accentGreen;
    } else if (trip.status == 'في الطريق') {
      statusBg = AppColors.amberLight;
      statusColor = AppColors.accentAmber;
    } else {
      statusBg = AppColors.blueLight;
      statusColor = AppColors.accentBlue;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Bus Type / Capacity Badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Route & Driver & Bus Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        trip.route,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'الحافلة: ${trip.busPlate} • السائق: ${trip.driverName}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Financial & Passengers Summary
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${trip.totalRevenue.toInt()} دج',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                trip.extraAmount > 0
                    ? '${trip.passengers} راكب (+${trip.extraAmount.toInt()} دج طرود)'
                    : '${trip.passengers} راكب (${trip.seatPrice.toInt()} دج)',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'أجرة السائق: ${trip.driverWage.toInt()} دج',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentAmber,
                ),
              ),
            ],
          ),

          if (onDeleteTrip != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDeleteTrip,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 18),
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
    );
  }
}
