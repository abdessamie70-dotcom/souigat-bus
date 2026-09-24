class BusModel {
  final String id;
  final String plateNumber;
  final String modelName;
  final int capacity; // Always 50 seats for large buses
  final String status; // 'جاهزة', 'في رحلة', 'صيانة'
  final int mileageKm;
  final String lastServiceDate;

  const BusModel({
    required this.id,
    required this.plateNumber,
    this.modelName = '',
    this.capacity = 50,
    required this.status,
    required this.mileageKm,
    required this.lastServiceDate,
  });

  static List<BusModel> defaultBuses() {
    return const [
      BusModel(
        id: 'BUS-01',
        plateNumber: '00142-120-47',
        capacity: 50,
        status: 'جاهزة للخدمة',
        mileageKm: 142500,
        lastServiceDate: '2024-09-10',
      ),
      BusModel(
        id: 'BUS-02',
        plateNumber: '00891-121-47',
        capacity: 50,
        status: 'في رحلة',
        mileageKm: 98400,
        lastServiceDate: '2024-09-18',
      ),
      BusModel(
        id: 'BUS-03',
        plateNumber: '00552-118-47',
        capacity: 50,
        status: 'صيانة دورية',
        mileageKm: 215300,
        lastServiceDate: '2024-09-22',
      ),
      BusModel(
        id: 'BUS-04',
        plateNumber: '01204-122-47',
        capacity: 50,
        status: 'جاهزة للخدمة',
        mileageKm: 64200,
        lastServiceDate: '2024-09-15',
      ),
    ];
  }
}
