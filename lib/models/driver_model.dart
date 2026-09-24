enum AttendanceStatus {
  work, // عمل
  rest, // راحة
  absence, // غياب
}

enum ShiftPattern {
  oneWorkOneRest, // يوم عمل / يوم راحة
  twoWorkTwoRest, // يومين عمل / يومين راحة
  oneWorkTwoRest, // يوم عمل / يومين راحة
  allWork,        // كل أيام عمل
}

extension ShiftPatternExtension on ShiftPattern {
  String get title {
    switch (this) {
      case ShiftPattern.oneWorkOneRest:
        return 'يوم عمل / يوم راحة';
      case ShiftPattern.twoWorkTwoRest:
        return 'يومين عمل / يومين راحة';
      case ShiftPattern.oneWorkTwoRest:
        return 'يوم عمل / يومين راحة';
      case ShiftPattern.allWork:
        return 'كل أيام عمل';
    }
  }

  String get shortCode {
    switch (this) {
      case ShiftPattern.oneWorkOneRest:
        return '1 / 1';
      case ShiftPattern.twoWorkTwoRest:
        return '2 / 2';
      case ShiftPattern.oneWorkTwoRest:
        return '1 / 2';
      case ShiftPattern.allWork:
        return 'كل الأيام';
    }
  }

  String get description {
    switch (this) {
      case ShiftPattern.oneWorkOneRest:
        return 'مناوبة يوم عمل يليه يوم راحة بالتبادل';
      case ShiftPattern.twoWorkTwoRest:
        return 'يومان عمل متتاليان يليهما يومان راحة';
      case ShiftPattern.oneWorkTwoRest:
        return 'يوم عمل واحد يليه يومان راحة متتاليان';
      case ShiftPattern.allWork:
        return 'العمل طيلة أيام الشهر (يومي متواصل)';
    }
  }
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get arabicLabel {
    switch (this) {
      case AttendanceStatus.work:
        return 'عمل';
      case AttendanceStatus.rest:
        return 'راحة';
      case AttendanceStatus.absence:
        return 'غياب';
    }
  }
}

class DriverModel {
  final String id;
  String name;
  String phone;
  String licenseType;
  String assignedBus;
  double dailyWage; // أجر اليومية بالدينار الجزائري (دج)
  double loanAmount; // المبلغ المقترض / سلفة تخصم من الأجرة الشهرية (دج)
  double rating;

  // Monthly Attendance: Map of Day number (1..31) to AttendanceStatus (عمل / راحة / غياب)
  Map<int, AttendanceStatus> monthlyAttendance;

  // Current selected shift pattern for quick reference
  ShiftPattern currentPattern;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseType,
    required this.assignedBus,
    this.dailyWage = 4000.0,
    this.loanAmount = 0.0,
    required this.rating,
    this.currentPattern = ShiftPattern.oneWorkOneRest,
    Map<int, AttendanceStatus>? monthlyAttendance,
  }) : monthlyAttendance = monthlyAttendance ?? _initPatternAttendance(currentPattern);

  void updateDetails({
    String? newName,
    String? newPhone,
    String? newLicenseType,
    String? newAssignedBus,
    double? newDailyWage,
    double? newLoanAmount,
    ShiftPattern? newPattern,
  }) {
    if (newName != null && newName.trim().isNotEmpty) {
      name = newName.trim();
    }
    if (newPhone != null && newPhone.trim().isNotEmpty) {
      phone = newPhone.trim();
    }
    if (newLicenseType != null && newLicenseType.trim().isNotEmpty) {
      licenseType = newLicenseType.trim();
    }
    if (newAssignedBus != null && newAssignedBus.trim().isNotEmpty) {
      assignedBus = newAssignedBus.trim();
    }
    if (newDailyWage != null && newDailyWage > 0) {
      dailyWage = newDailyWage;
    }
    if (newLoanAmount != null && newLoanAmount >= 0) {
      loanAmount = newLoanAmount;
    }
    if (newPattern != null) {
      applyPattern(newPattern);
    }
  }

  DriverModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? licenseType,
    String? assignedBus,
    double? dailyWage,
    double? loanAmount,
    double? rating,
    ShiftPattern? currentPattern,
    Map<int, AttendanceStatus>? monthlyAttendance,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseType: licenseType ?? this.licenseType,
      assignedBus: assignedBus ?? this.assignedBus,
      dailyWage: dailyWage ?? this.dailyWage,
      loanAmount: loanAmount ?? this.loanAmount,
      rating: rating ?? this.rating,
      currentPattern: currentPattern ?? this.currentPattern,
      monthlyAttendance: monthlyAttendance ?? Map.from(this.monthlyAttendance),
    );
  }

  static Map<int, AttendanceStatus> _initPatternAttendance(ShiftPattern pattern, {int daysCount = 31}) {
    final Map<int, AttendanceStatus> map = {};
    for (int day = 1; day <= daysCount; day++) {
      switch (pattern) {
        case ShiftPattern.allWork:
          // كل الأيام عمل
          map[day] = AttendanceStatus.work;
          break;
        case ShiftPattern.oneWorkOneRest:
          // عمل يوم وراحة يوم (فردي عمل ، زوجي راحة)
          map[day] = (day % 2 != 0) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
        case ShiftPattern.twoWorkTwoRest:
          // يومين عمل ويومين راحة (دورة من 4 أيام)
          final cycle = (day - 1) % 4;
          map[day] = (cycle == 0 || cycle == 1) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
        case ShiftPattern.oneWorkTwoRest:
          // عمل يوم وراحة يومان (دورة من 3 أيام)
          final cycle = (day - 1) % 3;
          map[day] = (cycle == 0) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
      }
    }
    return map;
  }

  AttendanceStatus getDayStatus(int day) {
    return monthlyAttendance[day] ?? AttendanceStatus.work;
  }

  bool isWorkingOnDay(int day) {
    return getDayStatus(day) == AttendanceStatus.work;
  }

  void applyPattern(ShiftPattern pattern, {int daysCount = 31}) {
    currentPattern = pattern;
    for (int day = 1; day <= daysCount; day++) {
      switch (pattern) {
        case ShiftPattern.allWork:
          monthlyAttendance[day] = AttendanceStatus.work;
          break;
        case ShiftPattern.oneWorkOneRest:
          monthlyAttendance[day] = (day % 2 != 0) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
        case ShiftPattern.twoWorkTwoRest:
          final cycle = (day - 1) % 4;
          monthlyAttendance[day] = (cycle == 0 || cycle == 1) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
        case ShiftPattern.oneWorkTwoRest:
          final cycle = (day - 1) % 3;
          monthlyAttendance[day] = (cycle == 0) ? AttendanceStatus.work : AttendanceStatus.rest;
          break;
      }
    }
  }

  // Attendance metrics
  int get workDaysCount =>
      monthlyAttendance.values.where((s) => s == AttendanceStatus.work).length;

  int get restDaysCount =>
      monthlyAttendance.values.where((s) => s == AttendanceStatus.rest).length;

  int get absenceDaysCount =>
      monthlyAttendance.values.where((s) => s == AttendanceStatus.absence).length;

  // إجمالي مستحقات السائق للشهر = عدد أيام العمل × أجر اليومية
  double get grossMonthlyWages => workDaysCount * dailyWage;

  // صافي أجرة السائق بعد خصم السلفة / القرض
  double get netMonthlyWages {
    final net = grossMonthlyWages - loanAmount;
    return net > 0 ? net : 0.0;
  }

  // للحفاظ على التوافق مع الكود القائم
  double get totalMonthlyWages => netMonthlyWages;

  static List<DriverModel> defaultDrivers() {
    final list = [
      DriverModel(
        id: 'DRV-01',
        name: 'محمد بلقاسم',
        phone: '0661 23 45 67',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '00142-120-47',
        dailyWage: 4000,
        loanAmount: 5000, // سلفة 5000 دج كمثال
        rating: 4.9,
        currentPattern: ShiftPattern.oneWorkOneRest,
      ),
      DriverModel(
        id: 'DRV-02',
        name: 'إبراهيم تواتي',
        phone: '0550 98 76 54',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '00891-121-47',
        dailyWage: 4000,
        loanAmount: 0,
        rating: 4.8,
        currentPattern: ShiftPattern.twoWorkTwoRest,
      ),
      DriverModel(
        id: 'DRV-03',
        name: 'أحمد سعيدي',
        phone: '0772 11 22 33',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '01204-122-47',
        dailyWage: 4000,
        loanAmount: 10000, // سلفة 10000 دج كمثال
        rating: 4.7,
        currentPattern: ShiftPattern.oneWorkOneRest,
      ),
      DriverModel(
        id: 'DRV-04',
        name: 'عبد القادر مرابط',
        phone: '0663 44 55 66',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '00552-118-47',
        dailyWage: 4000,
        loanAmount: 0,
        rating: 4.9,
        currentPattern: ShiftPattern.allWork,
      ),
      DriverModel(
        id: 'DRV-05',
        name: 'عمر حمادي',
        phone: '0558 77 88 99',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '00142-120-47',
        dailyWage: 4000,
        loanAmount: 0,
        rating: 4.6,
        currentPattern: ShiftPattern.oneWorkTwoRest,
      ),
      DriverModel(
        id: 'DRV-06',
        name: 'ياسين بن علي',
        phone: '0779 33 22 11',
        licenseType: 'صنف د (نقل عمومي)',
        assignedBus: '00891-121-47',
        dailyWage: 4000,
        loanAmount: 0,
        rating: 4.8,
        currentPattern: ShiftPattern.oneWorkOneRest,
      ),
    ];
    // Ensure today (day 24) has realistic active working drivers and 1 rest, 1 absence
    list[0].monthlyAttendance[24] = AttendanceStatus.work;
    list[1].monthlyAttendance[24] = AttendanceStatus.work;
    list[2].monthlyAttendance[24] = AttendanceStatus.work;
    list[3].monthlyAttendance[24] = AttendanceStatus.work;
    list[4].monthlyAttendance[24] = AttendanceStatus.rest;
    list[5].monthlyAttendance[24] = AttendanceStatus.work;
    return list;
  }
}
