import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';

class EditDriverModal extends StatefulWidget {
  final DriverModel? driver; // Null if adding a new driver
  final Function(DriverModel savedDriver) onDriverSaved;

  const EditDriverModal({
    super.key,
    this.driver,
    required this.onDriverSaved,
  });

  @override
  State<EditDriverModal> createState() => _EditDriverModalState();
}

class _EditDriverModalState extends State<EditDriverModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _busController;
  late TextEditingController _licenseController;
  late TextEditingController _wageController;
  late ShiftPattern _selectedPattern;

  bool get isEditing => widget.driver != null;

  final List<String> _suggestedBuses = [
    '00142-120-47 (مرسيدس ترافيكو)',
    '00891-121-47 (مان ليونز كوتش)',
    '01204-122-47 (سوناكوم سفر)',
    '00552-118-47 (فولفو 9700)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phone ?? '');
    _busController = TextEditingController(text: widget.driver?.assignedBus ?? '');
    _licenseController = TextEditingController(
      text: widget.driver?.licenseType ?? 'صنف د (نقل عمومي)',
    );
    _wageController = TextEditingController(
      text: widget.driver != null ? widget.driver!.dailyWage.toInt().toString() : '4000',
    );
    _selectedPattern = widget.driver?.currentPattern ?? ShiftPattern.dayByDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _busController.dispose();
    _licenseController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  void _saveDriver() {
    if (_formKey.currentState?.validate() ?? false) {
      final double wage = double.tryParse(_wageController.text) ?? 4000;

      if (isEditing) {
        widget.driver!.updateDetails(
          newName: _nameController.text.trim(),
          newPhone: _phoneController.text.trim(),
          newLicenseType: _licenseController.text.trim(),
          newAssignedBus: _busController.text.trim(),
          newDailyWage: wage,
          newPattern: _selectedPattern,
        );
        widget.onDriverSaved(widget.driver!);
      } else {
        final newDriver = DriverModel(
          id: 'DRV-${DateTime.now().millisecondsSinceEpoch % 10000}',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          assignedBus: _busController.text.trim(),
          licenseType: _licenseController.text.trim(),
          dailyWage: wage,
          currentPattern: _selectedPattern,
        );
        newDriver.monthlyAttendance[DateTime.now().day] = AttendanceStatus.work;
        widget.onDriverSaved(newDriver);
      }

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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'تعديل بيانات السائق' : 'إضافة سائق جديد',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'مؤسسة سويقات • ${widget.driver!.id}'
                                : 'تسجيل سائق جديد في أسطول المؤسسة',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 18),

              // 1. Driver Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'اسم السائق الكامل',
                  hintText: 'مثال: محمد بلقاسم',
                  prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.accentBlue, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
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
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'الرجاء إدخال اسم السائق';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 2. Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '0661 23 45 67',
                  prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.accentGreen, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
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
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 3. Assigned Bus Field
              TextFormField(
                controller: _busController,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'رقم الحافلة المخصصة',
                  hintText: 'مثال: 00142-120-47',
                  prefixIcon: const Icon(Icons.directions_bus_rounded, color: AppColors.accentBlue, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
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
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الحافلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick suggested buses chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _suggestedBuses.map((busText) {
                  final plate = busText.split(' ').first;
                  return ActionChip(
                    label: Text(
                      plate,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: AppColors.blueLight,
                    side: const BorderSide(color: AppColors.borderBlue),
                    onPressed: () {
                      setState(() {
                        _busController.text = plate;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // 4. License & Daily Wage Row
              Row(
                children: [
                  // License Category
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _licenseController,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        labelText: 'رخصة السياقة',
                        hintText: 'صنف د (نقل عمومي)',
                        prefixIcon: const Icon(Icons.card_membership_rounded, color: AppColors.accentBlue, size: 18),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Daily Wage
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _wageController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.accentGreen),
                      decoration: InputDecoration(
                        labelText: 'اليومية (دج)',
                        hintText: '4000',
                        prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.accentGreen, size: 18),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) {
                          return 'قيمة غير صالحة';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Shift Pattern Selection (نظام المناوبة المعتمد)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نظام المناوبة المعتمد للسائق:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ShiftPattern.values.map((pattern) {
                        final bool isSelected = _selectedPattern == pattern;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPattern = pattern;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accentBlue : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accentBlue : AppColors.borderLight,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accentBlue.withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    pattern.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: Save & Cancel
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _saveDriver,
                      icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      label: Text(
                        isEditing ? 'حفظ بيانات السائق' : 'إضافة وتثبيت السائق',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
}
