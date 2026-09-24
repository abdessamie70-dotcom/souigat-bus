import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BookingPortalScreen extends StatefulWidget {
  const BookingPortalScreen({super.key});

  @override
  State<BookingPortalScreen> createState() => _BookingPortalScreenState();
}

class _BookingPortalScreenState extends State<BookingPortalScreen> {
  final Set<int> _selectedSeats = {};
  final Set<int> _reservedSeats = {3, 4, 8, 12, 15, 16, 22, 25, 30, 31, 40, 41, 45, 48};
  final double _seatPrice = 1300.0; // DZD

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'بوابة الحجز وتذاكر الركاب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'حافلة 50 مقعد',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'حجز المقاعد مباشرة مع تحديث الحساب اليومي للسائق بدون وقود',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _legendItem(AppColors.primaryDarkBlue, 'محجوز', hasBorder: true),
                    const SizedBox(width: 14),
                    _legendItem(AppColors.accentOrange, 'محدد'),
                    const SizedBox(width: 14),
                    _legendItem(Colors.white, 'متاح', hasBorder: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bus Seat Grid (50 seats)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06152238),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Front of Bus Driver Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'مقدمة الحافلة (مقود السائق 🚌)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      Text('باب الركاب 🚪', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Grid of 50 seats (4 seats per row: 2 on right, aisle, 2 on left)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 50,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final seatNum = index + 1;
                    final isReserved = _reservedSeats.contains(seatNum);
                    final isSelected = _selectedSeats.contains(seatNum);

                    Color bg = Colors.white;
                    Color textCol = AppColors.textPrimary;
                    if (isReserved) {
                      bg = AppColors.primaryDarkBlue;
                      textCol = Colors.white;
                    } else if (isSelected) {
                      bg = AppColors.accentOrange;
                      textCol = Colors.white;
                    }

                    return GestureDetector(
                      onTap: isReserved
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSeats.remove(seatNum);
                                } else {
                                  _selectedSeats.add(seatNum);
                                }
                              });
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isReserved
                                ? AppColors.primaryDarkBlue
                                : isSelected
                                    ? AppColors.accentOrange
                                    : AppColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'م $seatNum',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: textCol,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total Price & Confirm
          if (_selectedSeats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المقاعد المحددة: ${_selectedSeats.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'الإجمالي: ${(_selectedSeats.length * _seatPrice).toInt()} دج',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تأكيد حجز ${_selectedSeats.length} مقاعد بمبلغ ${(_selectedSeats.length * _seatPrice).toInt()} دج',
                          ),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                      setState(() {
                        _reservedSeats.addAll(_selectedSeats);
                        _selectedSeats.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تأكيد الحجز',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text, {bool hasBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: Colors.white24) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
