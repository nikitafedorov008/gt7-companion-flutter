import 'gt7info_data.dart'; // For CarData compatibility

class GTDBData {
  final List<GTDBCar> usedCars;
  final List<GTDBCar> legendCars;

  GTDBData({
    required this.usedCars,
    required this.legendCars,
  });

  factory GTDBData.fromJson(Map<String, dynamic> json) {
    final usedCars = <GTDBCar>[];
    final legendCars = <GTDBCar>[];

    // Parse used cars if available in the response
    if (json['data'] != null && json['data']['gt_car'] != null) {
      final usedCarList = json['data']['gt_car'] as List;
      usedCars.addAll(usedCarList.map((car) => GTDBCar.fromUsedCarJson(car)).toList());
    }

    // Parse legend cars if available in the response
    if (json['data'] != null && json['data']['gt_car'] != null) {
      final legendCarList = json['data']['gt_car'] as List;
      legendCars.addAll(legendCarList.map((car) => GTDBCar.fromLegendCarJson(car)).toList());
    }

    return GTDBData(
      usedCars: usedCars,
      legendCars: legendCars,
    );
  }
}

class GTDBCar {
  final int id;
  final String? name;
  final String? shortName;
  final String? slug;
  final String? manufacturerName;
  final String? state;
  final int? price;
  final String? image;
  final String? frontImage;
  final String? updatedAt;
  final Map<String, dynamic>? details; // For used cars
  final int? sort; // For legend cars

  GTDBCar({
    required this.id,
    this.name,
    this.shortName,
    this.slug,
    this.manufacturerName,
    this.state,
    this.price,
    this.image,
    this.frontImage,
    this.updatedAt,
    this.details,
    this.sort,
  });

  // Constructor for used cars from the API response
  factory GTDBCar.fromUsedCarJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final manufacturer = json['manufacturer'] as Map<String, dynamic>?;

    return GTDBCar(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      slug: json['slug'] ?? '',
      manufacturerName: manufacturer?['name'] ?? '',
      state: details?['used_state'], // Used car specific
      price: details?['used_price'] ?? details?['price'], // Use used_price if available, otherwise price
      image: details?['thumbnail_image_id'] != null 
          ? 'https://www.gran-turismo.com/common/dist/gt7/carlist/car_thumbnails/car${details?['thumbnail_image_id']}.png'
          : null,
      frontImage: null, // Not typically available for used cars
      updatedAt: json['updated_at'] ?? '',
      details: details,
      sort: null, // Not applicable for used cars
    );
  }

  // Constructor for legend cars from the API response
  factory GTDBCar.fromLegendCarJson(Map<String, dynamic> json) {
    final manufacturer = json['manufacturer'] as Map<String, dynamic>?;

    return GTDBCar(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      slug: json['slug'] ?? '',
      manufacturerName: manufacturer?['name'] ?? '',
      state: json['state'],
      price: json['price'],
      image: json['image'] != null
          ? 'https://www.gran-turismo.com/common/dist/gt7/carlist/car_thumbnails/car${json['image']}.png'
          : null,
      frontImage: json['frontImage'] != null
          ? 'https://www.gran-turismo.com/common/dist/gt7/carlist/car_thumbnails/car${json['frontImage']}.png'
          : null,
      updatedAt: json['updated_at'] ?? '',
      details: null, // Not applicable for legend cars
      sort: json['sort'],
    );
  }

  // Helper getters for common properties
  String get displayName => name ?? shortName ?? 'Unknown Car';
  
  String get displayPrice => 'Cr. ${_formatCredits(price ?? 0)}';
  
  bool get isSoldOut => state == 'soldout';
  bool get isLimitedStock => state == 'limited';
  bool get isNew => state == 'new';
  
  String get statusText {
    if (isSoldOut) return 'SOLD OUT';
    if (isLimitedStock) return 'LIMITED';
    if (isNew) return 'NEW';
    return 'AVAILABLE';
  }

  String get carId => 'car$id'; // Format car ID for image URLs

  String _formatCredits(int credits) {
    if (credits == 0) return '0';
    return credits.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},'
    );
  }

  // Convert GTDBCar to CarData for compatibility with existing widgets
  CarData toCarData() {
    return CarData(
      carId: carId,
      manufacturer: manufacturerName ?? 'Unknown',
      region: 'xx', // Default region
      name: displayName,
      credits: price ?? 0,
      state: state ?? 'normal',
      estimateDays: 0, // Default value
      maxEstimateDays: 0, // Default value
      isNew: isNew,
      rewardCar: null, // Default value
      engineSwap: null, // Default value
      lotteryCar: null, // Default value
      trophyCar: null, // Default value
    );
  }
}