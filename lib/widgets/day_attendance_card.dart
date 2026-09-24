import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';

class DayAttendanceCard extends StatelessWidget {
  final int dayNumber;
  final String dayName;
  final AttendanceStatus currentStatus;
  final Function(AttendanceStatus) onStatusSelected;

  const DayAttendanceCard({
    super.key,
    required this.dayNumber,
    required this.dayName,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color borderCol;
    Color statusBadgeColor;
    String statusText;

    switch (currentStatus) {
      case AttendanceStatus.work:
        cardBg = AppColors.greenLight.withOpacity(0.5);
        borderCol = AppColors.accentGreen.withOpacity(0.4);
        statusBadgeColor = AppColors.accentGreen;
        statusText = 'عمل';
        break;
      case AttendanceStatus.rest:
        cardBg = AppColors.amberLight.withOpacity(0.5);
        borderCol = AppColors.accentAmber.withOpacity(0.4);
        statusBadgeColor = AppColors.accentAmber;
        statusText = 'راحة';
        break;
      case AttendanceStatus.absence:
        cardBg = AppColors.redLight.withOpacity(0.5);
        borderCol = AppColors.accentRed.withOpacity(0.4);
        statusBadgeColor = AppColors.accentRed;
        statusText = 'غياب';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06152238),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day Header: Day Number + Day Name + Current Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusBadgeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 3 Segmented Toggle Buttons: [ عمل | راحة | غياب ]
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusBtn(
                    label: 'عمل',
                    target: AttendanceStatus.work,
                    activeColor: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildStatusBtn(
                    label: 'راحة',
                    target: AttendanceStatus.rest,
                    activeColor: AppColors.accentAmber,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildStatusBtn(
                    label: 'غياب',
                    target: AttendanceStatus.absence,
                    activeColor: AppColors.accentRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBtn({
    required String label,
    required AttendanceStatus target,
    required Color activeColor,
  }) {
    final bool isSelected = currentStatus == target;
    return GestureDetector(
      onTap: () => onStatusSelected(target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
