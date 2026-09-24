import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import 'today_driver_card.dart';

class DriverDailyCard extends StatelessWidget {
  final DriverModel driver;
  final Function(AttendanceStatus) onStatusChanged;
  final VoidCallback? onToggleSettlement;
  final VoidCallback? onEditDriver;

  const DriverDailyCard({
    super.key,
    required this.driver,
    required this.onStatusChanged,
    this.onToggleSettlement,
    this.onEditDriver,
  });

  @override
  Widget build(BuildContext context) {
    return TodayDriverCard(
      driver: driver,
      todayDay: DateTime.now().day,
      onStatusChanged: onStatusChanged,
      onEditDriver: onEditDriver,
    );
  }
}
