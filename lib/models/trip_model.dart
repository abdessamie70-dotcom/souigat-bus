class TripModel {
  final String id;
  final String route;
  final String busPlate;
  final String driverName;
  final int passengers; // عدد المقاعد المحجوزة / الركاب (الحد الأقصى 50)
  final double seatPrice; // سعر المقعد الواحد بالدينار (دج)
  final double extraAmount; // خانة مبلغ إضافي (شحن طرود / أمتعة زائدة دج)
  final double driverWage; // أجرة السائق للرحلة بالدينار دج
  final DateTime date;
  String status; // 'مكتملة', 'في الطريق', 'مجدولة', 'جاهزة للانطلاق'
  final String departureTime;
  final String arrivalTime;
  final String busModel;

  TripModel({
    required this.id,
    required this.route,
    required this.busPlate,
    required this.driverName,
    required this.passengers,
    this.seatPrice = 1200.0,
    this.extraAmount = 0.0,
    double? ticketRevenue,
    this.driverWage = 4000,
    required this.date,
    required this.status,
    this.departureTime = '08:00 ص',
    this.arrivalTime = '16:00 م',
    this.busModel = '',
  }) : _customRevenue = ticketRevenue;

  final double? _customRevenue;

  // إيراد المقاعد = عدد المقاعد × سعر المقعد الواحد
  double get seatsRevenue => passengers * seatPrice;

  // إجمالي إيرادات الرحلة = إيراد المقاعد + المبلغ الإضافي
  double get totalRevenue => _customRevenue ?? (seatsRevenue + extraAmount);

  // متوافق مع الاستخدامات السابقة
  double get ticketRevenue => totalRevenue;

  // صافي الدخل من الرحلة = الإجمالي - مستحقات السائق
  double get netIncome => totalRevenue - driverWage;
  double get occupancyPercentage => (passengers / 50.0) * 100.0;

  TripModel copyWith({
    String? id,
    String? route,
    String? busPlate,
    String? driverName,
    int? passengers,
    double? seatPrice,
    double? extraAmount,
    double? ticketRevenue,
    double? driverWage,
    DateTime? date,
    String? status,
    String? departureTime,
    String? arrivalTime,
    String? busModel,
  }) {
    return TripModel(
      id: id ?? this.id,
      route: route ?? this.route,
      busPlate: busPlate ?? this.busPlate,
      driverName: driverName ?? this.driverName,
      passengers: passengers ?? this.passengers,
      seatPrice: seatPrice ?? this.seatPrice,
      extraAmount: extraAmount ?? this.extraAmount,
      ticketRevenue: ticketRevenue ?? this.ticketRevenue,
      driverWage: driverWage ?? this.driverWage,
      date: date ?? this.date,
      status: status ?? this.status,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      busModel: busModel ?? this.busModel,
    );
  }

  static List<TripModel> sampleTrips() {
    return [
      TripModel(
        id: 'TRIP-101',
        route: 'أدرار ⟵ الجزائر العاصمة',
        busPlate: '00142-120-47',
        driverName: 'محمد بلقاسم',
        passengers: 48,
        ticketRevenue: 65000,
        driverWage: 4000,
        departureTime: '06:30 ص',
        arrivalTime: '18:30 م',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'في الطريق',
      ),
      TripModel(
        id: 'TRIP-102',
        route: 'غرداية ⟵ وهران',
        busPlate: '00891-121-47',
        driverName: 'إبراهيم تواتي',
        passengers: 50,
        ticketRevenue: 52800,
        driverWage: 4000,
        departureTime: '08:00 ص',
        arrivalTime: '17:00 م',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'في الطريق',
      ),
      TripModel(
        id: 'TRIP-103',
        route: 'ورقلة ⟵ قسنطينة',
        busPlate: '01204-122-47',
        driverName: 'أحمد سعيدي',
        passengers: 46,
        ticketRevenue: 55200,
        driverWage: 4000,
        departureTime: '13:30 م',
        arrivalTime: '21:00 م',
        date: DateTime.now().add(const Duration(hours: 1)),
        status: 'جاهزة للانطلاق',
      ),
      TripModel(
        id: 'TRIP-104',
        route: 'تمنراست ⟵ أدرار',
        busPlate: '00552-118-47',
        driverName: 'عبد القادر مرابط',
        passengers: 44,
        ticketRevenue: 55000,
        driverWage: 4000,
        departureTime: '19:00 م',
        arrivalTime: '05:00 ص',
        date: DateTime.now().add(const Duration(hours: 5)),
        status: 'مجدولة',
      ),
      TripModel(
        id: 'TRIP-105',
        route: 'الجزائر العاصمة ⟵ بسكرة',
        busPlate: '00142-120-47',
        driverName: 'ياسين بن علي',
        passengers: 49,
        ticketRevenue: 60000,
        driverWage: 4000,
        departureTime: '21:30 م',
        arrivalTime: '04:00 ص',
        date: DateTime.now().add(const Duration(hours: 7)),
        status: 'مجدولة',
      ),
    ];
  }
}
