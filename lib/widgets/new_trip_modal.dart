import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';

class NewTripModal extends StatefulWidget {
  final List<DriverModel> drivers;
  final Function(TripModel newTrip, int selectedDriverIndex) onTripAdded;

  const NewTripModal({
    super.key,
    required this.drivers,
    required this.onTripAdded,
  });

  @override
  State<NewTripModal> createState() => _NewTripModalState();
}

class _NewTripModalState extends State<NewTripModal> {
  final _formKey = GlobalKey<FormState>();
  final _routeController = TextEditingController(text: 'أدرار ⟵ بشار');
  final _passengersController = TextEditingController(text: '48');
  final _revenueController = TextEditingController(text: '62400');
  final _driverWageController = TextEditingController(text: '4000');

  int _selectedDriverIndex = 0;
  String _selectedBus = 'مرسيدس ترافيكو (00142-120-47)';

  final List<String> _busList = [
    'مرسيدس ترافيكو (00142-120-47)',
    'مان ليونز كوتش (00891-121-47)',
    'سوناكوم نوميديا (00552-118-47)',
    'فولفو سياحية (01204-122-47)',
  ];

  @override
  void dispose() {
    _routeController.dispose();
    _passengersController.dispose();
    _revenueController.dispose();
    _driverWageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final passengers = int.tryParse(_passengersController.text) ?? 45;
      final revenue = double.tryParse(_revenueController.text) ?? 50000;
      final wage = double.tryParse(_driverWageController.text) ?? 4000;

      final driver = widget.drivers[_selectedDriverIndex];

      final newTrip = TripModel(
        id: 'TRIP-${DateTime.now().millisecondsSinceEpoch % 10000}',
        route: _routeController.text.trim(),
        busPlate: _selectedBus.split('(').last.replaceAll(')', ''),
        driverName: driver.name,
        passengers: passengers,
        ticketRevenue: revenue,
        driverWage: wage,
        date: DateTime.now(),
        status: 'مكتملة',
      );

      widget.onTripAdded(newTrip, _selectedDriverIndex);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_road_rounded,
                          color: AppColors.accentOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'تسجيل رحلة جديدة',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'حساب إيراد التذاكر وأجرة السائق مباشرة (بدون وقود)',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 16),

              // Route Input
              TextFormField(
                controller: _routeController,
                decoration: _inputDecoration('مسار / خط الرحلة', Icons.map_outlined),
                validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال المسار' : null,
              ),
              const SizedBox(height: 12),

              // Driver Dropdown (from Active Drivers)
              DropdownButtonFormField<int>(
                value: _selectedDriverIndex,
                decoration: _inputDecoration('السائق المسؤول', Icons.person_outline),
                items: List.generate(widget.drivers.length, (idx) {
                  final d = widget.drivers[idx];
                  return DropdownMenuItem<int>(
                    value: idx,
                    child: Text(
                      '${d.name} (${d.assignedBus})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  );
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDriverIndex = val);
                },
              ),
              const SizedBox(height: 12),

              // Bus Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBus,
                decoration: _inputDecoration('الحافلة المخصصة', Icons.directions_bus_outlined),
                items: _busList.map((bus) {
                  return DropdownMenuItem<String>(
                    value: bus,
                    child: Text(
                      bus,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBus = val);
                },
              ),
              const SizedBox(height: 12),

              // Passengers & Revenue Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passengersController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('عدد الركاب (من 50)', Icons.people_outline),
                      validator: (val) {
                        final num = int.tryParse(val ?? '');
                        if (num == null || num < 1 || num > 50) return 'بين 1 و 50';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _revenueController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('إجمالي التذاكر (دج)', Icons.monetization_on_outlined),
                      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Driver Wage Input
              TextFormField(
                controller: _driverWageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('أجرة / مستحقات السائق للرحلة (دج)', Icons.account_balance_wallet_outlined),
                validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال الأجرة' : null,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                label: const Text(
                  'حفظ الرحلة وتحديث الحساب اليومي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: AppColors.accentOrange),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.5),
      ),
    );
  }
}
