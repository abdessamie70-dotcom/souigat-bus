import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'sub_kpi_card.dart';

class MainHeaderBanner extends StatelessWidget {
  final VoidCallback onNewTripPressed;
  final double averagePassengers;
  final int occupancyRate;
  final int largeBusPassengers;
  final int largeBusTrips;

  const MainHeaderBanner({
    super.key,
    required this.onNewTripPressed,
    required this.averagePassengers,
    required this.occupancyRate,
    required this.largeBusPassengers,
    required this.largeBusTrips,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 650;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Row: Title + Orange Action Button
              isTablet
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTitleSection(),
                        _buildNewTripButton(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 14),
                        _buildNewTripButton(),
                      ],
                    ),

              const SizedBox(height: 18),
              const Divider(color: Color(0x1AFFFFFF), height: 1),
              const SizedBox(height: 18),

              // Sub-KPI Cards Grid (Responsive 4 items)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isTablet ? 1.35 : 1.15,
                children: [
                  // Sub-Card 1: متوسط الركاب للرحلة (Green Accent)
                  SubKpiCard(
                    title: 'متوسط الركاب للرحلة',
                    value: averagePassengers.toStringAsFixed(1),
                    unit: 'راكب',
                    valueColor: AppColors.accentGreen,
                    bottomText: 'سعة الحافلة: 50 مقعد',
                  ),

                  // Sub-Card 2: معدل الإشغال للحافلات الكبيرة (Orange Accent)
                  SubKpiCard(
                    title: 'معدل الإشغال للحافلات',
                    value: '$occupancyRate%',
                    unit: 'امتلاء',
                    valueColor: AppColors.accentOrange,
                    bottomText: 'الهدف: > 80%',
                    customBottomWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الهدف: > 80%',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              occupancyRate >= 80 ? 'ممتاز' : 'متوسط',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (occupancyRate / 100.0).clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFF334155),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentOrange,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sub-Card 3: ركاب الحافلات الكبيرة
                  SubKpiCard(
                    title: 'ركاب الحافلات الكبيرة',
                    value: '$largeBusPassengers',
                    unit: 'مسافر',
                    valueColor: AppColors.textWhite,
                    bottomText: 'خلال هذا الشهر',
                  ),

                  // Sub-Card 4: رحلات حافلات 50 مقعد
                  SubKpiCard(
                    title: 'رحلات حافلات 50 مقعد',
                    value: '$largeBusTrips',
                    unit: 'رحلة',
                    valueColor: AppColors.textWhite,
                    bottomText: 'حافلات سعة 50 مقعد',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 20),
            SizedBox(width: 6),
            Text(
              'بيانات حافلات النقل الكبيرة (سعة 50 راكب)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textWhite,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'معدلات ونسب الامتلاء للحافلات الكبيرة ومردودية المقاعد',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildNewTripButton() {
    return ElevatedButton.icon(
      onPressed: onNewTripPressed,
      icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
      label: const Text(
        'تسجيل رحلة جديدة',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
        shadowColor: AppColors.accentOrange.withOpacity(0.4),
      ),
    );
  }
}
