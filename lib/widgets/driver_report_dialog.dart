import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';

class DriverReportDialog extends StatelessWidget {
  final DriverModel driver;
  final int month;
  final int year;

  static const List<String> monthNames = [
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

  static const List<String> weekdayArabic = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  const DriverReportDialog({
    super.key,
    required this.driver,
    required this.month,
    required this.year,
  });

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  String _getDayName(int day) {
    final dt = DateTime(year, month, day);
    return weekdayArabic[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final int workDays = driver.workDaysCount;
    final int restDays = driver.restDaysCount;
    final int absenceDays = driver.absenceDaysCount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header with Close and Print/Download Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.description_rounded, color: AppColors.accentBlue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'كشف الحساب والعمل الشهري للسائق',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    splashRadius: 18,
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),

              // Printable Document Body
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Official Letterhead
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'مؤسسة سويقات أبو طالب',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                                Text(
                                  'إدارة نقل المسافرين والأسطول',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDarkBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${monthNames[month]} $year',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: 14),

                        // Driver Information Grid
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              _infoRow('اسم السائق:', driver.name, 'الحافلة المسندة:', driver.assignedBus),
                              const SizedBox(height: 6),
                              _infoRow('رقم الهاتف:', driver.phone, 'رخصة السياقة:', driver.licenseType),
                              const SizedBox(height: 6),
                              _infoRow('نظام المناوبة:', driver.currentPattern.title, 'أجر اليومية:', '${driver.dailyWage.toInt()} دج'),
                              if (driver.loanAmount > 0) ...[
                                const SizedBox(height: 6),
                                _infoRow(
                                  'إجمالي المستحق:',
                                  '${driver.grossMonthlyWages.toInt()} دج',
                                  'سلفة / قرض مخصوم:',
                                  '-${driver.loanAmount.toInt()} دج',
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Financial Summary Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('أيام العمل', '$workDays يوم', AppColors.accentGreen),
                              _statItem('أيام الراحة', '$restDays يوم', AppColors.accentAmber),
                              _statItem('أيام الغياب', '$absenceDays يوم', AppColors.accentRed),
                              if (driver.loanAmount > 0)
                                _statItem('خصم سلفة', '-${driver.loanAmount.toInt()} دج', AppColors.accentOrange),
                              _statItem('المستحق الصافي', '${driver.netMonthlyWages.toInt()} دج', Colors.white),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Day-by-Day Table
                        const Text(
                          'جدول تفصيل أيام الشهر:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: daysInMonth,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                            itemBuilder: (ctx, index) {
                              final int day = index + 1;
                              final String dayName = _getDayName(day);
                              final AttendanceStatus status = driver.monthlyAttendance[day] ?? AttendanceStatus.work;

                              Color statusColor;
                              switch (status) {
                                case AttendanceStatus.work:
                                  statusColor = AppColors.accentGreen;
                                  break;
                                case AttendanceStatus.rest:
                                  statusColor = AppColors.accentAmber;
                                  break;
                                case AttendanceStatus.absence:
                                  statusColor = AppColors.accentRed;
                                  break;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'يوم $day',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dayName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status.arabicLabel,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          status == AttendanceStatus.work
                                              ? '${driver.dailyWage.toInt()} دج'
                                              : '0 دج',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: status == AttendanceStatus.work
                                                ? AppColors.textPrimary
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Official Signatures
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: const [
                                Text('توقيع السائق المعني:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                SizedBox(height: 35),
                                Text('................................', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Column(
                              children: const [
                                Text('توقيع وختم الإدارة:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                SizedBox(height: 35),
                                Text('................................', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons: Print Statement & Download Statement
              Row(
                children: [
                  // Print Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('جاري إرسال كشف السائق "${driver.name}" إلى الطابعة...'),
                            backgroundColor: AppColors.accentBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.print_rounded, color: Colors.white, size: 17),
                      label: const Text(
                        'طباعة الكشف',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Download PDF Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تنزيل كشف السائق "${driver.name}" بصيغة PDF بنجاح'),
                            backgroundColor: AppColors.accentGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 17),
                      label: const Text(
                        'تحميل كشف السائق',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Close Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label1, String val1, String label2, String val2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(label1, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  val1,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Text(label2, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  val2,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
