import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';
import '../widgets/new_trip_modal.dart';
import '../widgets/trip_card.dart';

class DailyTripsScreen extends StatefulWidget {
  final List<TripModel> trips;
  final List<DriverModel> drivers;
  final Function(TripModel newTrip, int driverIndex) onTripAdded;
  final Function(int tripIndex)? onTripDeleted;

  const DailyTripsScreen({
    super.key,
    required this.trips,
    required this.drivers,
    required this.onTripAdded,
    this.onTripDeleted,
  });

  @override
  State<DailyTripsScreen> createState() => _DailyTripsScreenState();
}

class _DailyTripsScreenState extends State<DailyTripsScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';

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

  void _confirmDeleteTrip(int index, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
            SizedBox(width: 8),
            Text('تأكيد حذف الرحلة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل تريد حذف رحلة "${trip.route}" المجدولة على الساعة ${trip.departureTime}؟',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onTripDeleted?.call(index);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف رحلة "${trip.route}" بنجاح'),
                  backgroundColor: AppColors.accentRed,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('حذف الرحلة', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = widget.trips.where((t) {
      final matchesSearch = t.route.contains(_searchQuery) ||
          t.driverName.contains(_searchQuery) ||
          t.busPlate.contains(_searchQuery);
      final matchesStatus = _selectedStatus == 'all' || t.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    int totalPassengers = 0;
    for (final t in widget.trips) {
      totalPassengers += t.passengers;
    }
    final int tripsCount = widget.trips.length;
    final double avgPassengers = tripsCount > 0 ? totalPassengers / tripsCount : 0.0;
    final int occupancy = ((avgPassengers / 50.0) * 100.0).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Action Button
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22152238),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'سجل الرحلات اليومي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'متابعة رحلات حافلات النقل والخطوط اليومية',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _openNewTripModal,
                      icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'تسجيل رحلة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem('إجمالي الرحلات', '$tripsCount رحلة', Colors.white),
                    _metricItem('إجمالي الركاب', '$totalPassengers مسافر', AppColors.accentGreen),
                    _metricItem('معدل الإشغال', '$occupancy%', AppColors.accentOrange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: const InputDecoration(
                      hintText: 'بحث بالمسار أو السائق أو الحافلة...',
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _searchQuery = ''),
                    splashRadius: 16,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Trips List or Empty State
          if (filteredTrips.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderBlue),
                    ),
                    child: const Icon(Icons.alt_route_rounded, size: 30, color: AppColors.accentBlue),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.trips.isEmpty ? 'لا توجد رحلات مبرمجة حالياً' : 'لا توجد رحلات مطابقة للبحث',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.trips.isEmpty
                        ? 'يمكنك البدء ببرمجة رحلات حافلات المؤسسة وتحديد المسارات والسائقين'
                        : 'جرّب كتابة اسم مسار أو سائق أو رقم حافلة آخر',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.trips.isEmpty) ...[
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _openNewTripModal,
                      icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      label: const Text(
                        '+ برمجة رحلة جديدة',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTrips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final trip = filteredTrips[idx];
                final originalIndex = widget.trips.indexOf(trip);
                return TripCard(
                  trip: trip,
                  onDeleteTrip: () => _confirmDeleteTrip(originalIndex, trip),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
