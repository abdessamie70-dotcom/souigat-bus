import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PeriodSelectorBar extends StatelessWidget {
  final int currentMonth;
  final int currentYear;
  final Function(int month, int year) onPeriodChanged;

  static const List<String> monthNames = [
    '',
    'جانفي (01)',
    'فيفري (02)',
    'مارس (03)',
    'أفريل (04)',
    'ماي (05)',
    'جوان (06)',
    'جويلية (07)',
    'أوت (08)',
    'سبتمبر (09)',
    'أكتوبر (10)',
    'نوفمبر (11)',
    'ديسمبر (12)'
  ];

  static const List<String> monthShortNames = [
    '',
    'جانفي',
    'فيفري',
    'مارس',
    'أفريل',
    'ماي',
    'جوان',
    'جويلية',
    'أوت',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  const PeriodSelectorBar({
    super.key,
    required this.currentMonth,
    required this.currentYear,
    required this.onPeriodChanged,
  });

  void _stepMonth(int delta) {
    int m = currentMonth + delta;
    int y = currentYear;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }
    onPeriodChanged(m, y);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06152238),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month & Year Label with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.accentOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الفترة المحددة:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),

              // Month Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentMonth,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textPrimary),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    items: List.generate(12, (index) {
                      final m = index + 1;
                      return DropdownMenuItem<int>(
                        value: m,
                        child: Text(monthShortNames[m]),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) onPeriodChanged(val, currentYear);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Year Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentYear,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textPrimary),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    items: () {
                      final currentDeviceYear = DateTime.now().year;
                      final yearsSet = <int>{
                        currentDeviceYear - 2,
                        currentDeviceYear - 1,
                        currentDeviceYear,
                        currentDeviceYear + 1,
                        currentDeviceYear + 2,
                        currentYear,
                      };
                      final sortedYears = yearsSet.toList()..sort();
                      return sortedYears.map((y) {
                        return DropdownMenuItem<int>(
                          value: y,
                          child: Text('$y'),
                        );
                      }).toList();
                    }(),
                    onChanged: (val) {
                      if (val != null) onPeriodChanged(currentMonth, val);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Stepper Navigation buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _stepMonth(-1),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: AppColors.textPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${monthShortNames[currentMonth]} $currentYear',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _stepMonth(1),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
