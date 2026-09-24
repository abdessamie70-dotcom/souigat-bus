import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'attendance_wages_screen.dart';
import 'booking_screen.dart';
import 'daily_trips_screen.dart';
import 'dashboard_screen.dart';
import 'drivers_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late List<DriverModel> _drivers;
  late List<TripModel> _trips;

  @override
  void initState() {
    super.initState();
    _drivers = DriverModel.defaultDrivers();
    _trips = TripModel.sampleTrips();
  }

  void _onDriverUpdated(int index, DriverModel updatedDriver) {
    setState(() {
      _drivers[index] = updatedDriver;
    });
  }

  void _onTripAdded(TripModel newTrip, int driverIndex) {
    setState(() {
      _trips.insert(0, newTrip);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل رحلة "${newTrip.route}" بنجاح'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDriverDayStatusChanged(int driverIndex, int day, AttendanceStatus newStatus) {
    setState(() {
      _drivers[driverIndex].monthlyAttendance[day] = newStatus;
    });
  }

  void _onApplyShiftPattern(int driverIndex, ShiftPattern pattern) {
    setState(() {
      _drivers[driverIndex].applyPattern(pattern);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تطبيق نظام "${pattern.title}" على أيام الشهر للسائق ${_drivers[driverIndex].name}',
        ),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3 Main Screens requested in bottom bar:
    // 1. الرئيسية
    // 2. حضور وأجور السائقين
    // 3. سجل الرحلات اليومي
    final List<Widget> screens = [
      DashboardScreen(
        drivers: _drivers,
        trips: _trips,
        onTripAdded: _onTripAdded,
        onDriverDayStatusChanged: _onDriverDayStatusChanged,
        onApplyShiftPattern: _onApplyShiftPattern,
        onDriverUpdated: _onDriverUpdated,
      ),
      AttendanceWagesScreen(
        drivers: _drivers,
        onDriverDayStatusChanged: _onDriverDayStatusChanged,
        onApplyShiftPattern: _onApplyShiftPattern,
        onDriverUpdated: _onDriverUpdated,
      ),
      DailyTripsScreen(
        trips: _trips,
        drivers: _drivers,
        onTripAdded: _onTripAdded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomDashboardAppBar(
        onDriversTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: DriversScreen(
                  drivers: _drivers,
                  onDriverUpdated: _onDriverUpdated,
                ),
              ),
            ),
          );
        },
        onBookingTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'بوابة الحجز',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  backgroundColor: AppColors.cardWhite,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0.5,
                ),
                body: const Directionality(
                  textDirection: TextDirection.rtl,
                  child: BookingPortalScreen(),
                ),
              ),
            ),
          );
        },
        onNotificationsTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد إشعارات جديدة حالياً'),
              backgroundColor: AppColors.primaryDarkBlue,
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      // ==================== EXACT BOTTOM NAVIGATION BAR (الرئيسية ، حضور وأجور السائقين ، سجل الرحلات اليومي) ====================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: 0,
          items: const [
            // 1. الرئيسية
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.dashboard_rounded),
              ),
              label: 'الرئيسية',
            ),

            // 2. حضور وأجور السائقين
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.calendar_month_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.calendar_month_rounded),
              ),
              label: 'حضور وأجور السائقين',
            ),

            // 3. سجل الرحلات اليومي
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.directions_bus_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.directions_bus_rounded),
              ),
              label: 'سجل الرحلات اليومي',
            ),
          ],
        ),
      ),
    );
  }
}
