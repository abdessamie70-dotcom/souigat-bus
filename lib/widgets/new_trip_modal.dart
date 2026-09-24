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
  final _manualDriverController = TextEditingController();
  final _passengersController = TextEditingController(text: '45');
  final _seatPriceController = TextEditingController(text: '1200');
  final _extraAmountController = TextEditingController(text: '3500');
  final _driverWageController = TextEditingController(text: '4000');

  int? _selectedDriverIndex;
  String _selectedBus = 'مرسيدس ترافيكو (00142-120-47)';

  final List<String> _busList = [
    'مرسيدس ترافيكو (00142-120-47)',
    'مان ليونز كوتش (00891-121-47)',
    'سوناكوم نوميديا (00552-118-47)',
    'فولفو سياحية (01204-122-47)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.drivers.isNotEmpty) {
      _selectedDriverIndex = 0;
      // Pre-fill driver daily wage if available
      _driverWageController.text = widget.drivers[0].dailyWage.toInt().toString();
    } else {
      _manualDriverController.text = 'سائق المؤسسة';
    }
  }

  @override
  void dispose() {
    _routeController.dispose();
    _manualDriverController.dispose();
    _passengersController.dispose();
    _seatPriceController.dispose();
    _extraAmountController.dispose();
    _driverWageController.dispose();
    super.dispose();
  }

  int get _passengers => int.tryParse(_passengersController.text) ?? 0;
  double get _seatPrice => double.tryParse(_seatPriceController.text) ?? 0.0;
  double get _extraAmount => double.tryParse(_extraAmountController.text) ?? 0.0;
  double get _driverWage => double.tryParse(_driverWageController.text) ?? 0.0;

  double get _seatsRevenue => _passengers * _seatPrice;
  double get _totalRevenue => _seatsRevenue + _extraAmount;
  double get _netTripIncome => _totalRevenue - _driverWage;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final passengers = _passengers;
      final seatPrice = _seatPrice;
      final extraAmount = _extraAmount;
      final wage = _driverWage;

      final String driverName = (widget.drivers.isNotEmpty && _selectedDriverIndex != null)
          ? widget.drivers[_selectedDriverIndex!].name
          : _manualDriverController.text.trim();

      final newTrip = TripModel(
        id: 'TRIP-${DateTime.now().millisecondsSinceEpoch % 10000}',
        route: _routeController.text.trim(),
        busPlate: _selectedBus.split('(').last.replaceAll(')', ''),
        driverName: driverName.isNotEmpty ? driverName : 'سائق غير معيّن',
        passengers: passengers,
        seatPrice: seatPrice,
        extraAmount: extraAmount,
        driverWage: wage,
        date: DateTime.now(),
        status: 'مجدولة',
      );

      final int driverIndexToPass = _selectedDriverIndex ?? 0;
      widget.onTripAdded(newTrip, driverIndexToPass);
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
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderBlue),
                        ),
                        child: const Icon(
                          Icons.alt_route_rounded,
                          color: AppColors.accentBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'برمجة رحلة جديدة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'تسجيل خط سير حافلة مع السائق والمستحقات',
                            style: TextStyle(
                              fontSize: 11,
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

              // Driver Selector (Dropdown if drivers exist, or text field if empty)
              if (widget.drivers.isNotEmpty)
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
                )
              else
                TextFormField(
                  controller: _manualDriverController,
                  decoration: _inputDecoration('اسم السائق (لا يوجد سائقون مسجلون بعد)', Icons.person_outline),
                  validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال اسم السائق' : null,
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

              // Row 1: Passengers (المقاعد) & Seat Price (سعر المقعد)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passengersController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('عدد المقاعد / الركاب', Icons.airline_seat_recline_normal_rounded),
                      onChanged: (_) => setState(() {}),
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
                      controller: _seatPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('سعر المقعد (دج)', Icons.monetization_on_outlined),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        final p = double.tryParse(val ?? '');
                        if (p == null || p < 0) return 'قيمة غير صالحة';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Extra Amount (مبلغ إضافي) & Driver Wage (أجرة السائق)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _extraAmountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('مبلغ إضافي (طرود/أمتعة دج)', Icons.inventory_2_outlined),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
                          return 'قيمة غير صالحة';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _driverWageController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('أجرة السائق (دج)', Icons.account_balance_wallet_outlined),
                      onChanged: (_) => setState(() {}),
                      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dynamic Revenue Calculation Card (حساب إجمالي الإيرادات اللحظي)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تفصيل وحساب إيرادات الرحلة:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'حساب فوري تلقائي ⚡',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إيراد المقاعد ($_passengers مقعد × ${_seatPrice.toInt()} دج):',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_seatsRevenue.toInt()} دج',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مبلغ إضافي (شحن طرود وأمتعة):',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '+${_extraAmount.toInt()} دج',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي إيراد الرحلة:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryDarkBlue),
                          ),
                          Text(
                            '${_totalRevenue.toInt()} دج',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentGreen),
                          ),
                        ],
                      ),
                    ),
                    if (_driverWage > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'صافي بعد خصم أجرة السائق (${_driverWage.toInt()} دج):',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_netTripIncome.toInt()} دج',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _netTripIncome >= 0 ? AppColors.accentBlue : AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                label: const Text(
                  'حفظ وبرمجة الرحلة الآن',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
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
      prefixIcon: Icon(icon, size: 18, color: AppColors.accentBlue),
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
        borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
      ),
    );
  }
}
