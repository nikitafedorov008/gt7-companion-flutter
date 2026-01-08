import 'package:flutter/foundation.dart';
import '../models/unified_car_data.dart';
import '../services/gt7info_service.dart';
import '../services/gtdb_service.dart';
import '../models/gt7info_data.dart';
import '../models/gtdb_data.dart';

class UnifiedCarRepository extends ChangeNotifier {
  final GT7InfoService _gt7InfoService;
  final GTDBService _gtdbService;

  List<UnifiedCarData> _allCars = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UnifiedCarData> get allCars => _allCars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UnifiedCarRepository(this._gt7InfoService, this._gtdbService);

  Future<void> fetchAllCars({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch data from both services
      await _gt7InfoService.fetchGT7InfoData(forceRefresh: forceRefresh);
      await _gtdbService.fetchGTDBData(forceRefresh: forceRefresh);

      // Combine data from both sources
      final gt7InfoCars = _extractGT7InfoCars();
      final gtdbCars = _extractGTDBCars();

      // Combine and deduplicate cars
      final combinedCars = <String, UnifiedCarData>{};

      // Add GT7Info cars
      for (final car in gt7InfoCars) {
        combinedCars[car.id] = car;
      }

      // Add GTDB cars, potentially updating existing entries with more information
      for (final car in gtdbCars) {
        if (combinedCars.containsKey(car.id)) {
          // If car exists from both sources, merge information
          final existingCar = combinedCars[car.id]!;
          combinedCars[car.id] = _mergeCarData(existingCar, car);
        } else {
          combinedCars[car.id] = car;
        }
      }

      _allCars = combinedCars.values.toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading unified car data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UnifiedCarData> _extractGT7InfoCars() {
    final cars = <UnifiedCarData>[];
    
    if (_gt7InfoService.data != null) {
      final gt7Data = _gt7InfoService.data!;
      
      // Add used cars
      for (final car in gt7Data.used.cars) {
        cars.add(_convertGT7InfoCarToUnified(car, 'gt7info_used'));
      }
      
      // Add legend cars
      for (final car in gt7Data.legend.cars) {
        cars.add(_convertGT7InfoCarToUnified(car, 'gt7info_legend'));
      }
    }
    
    return cars;
  }

  List<UnifiedCarData> _extractGTDBCars() {
    final cars = <UnifiedCarData>[];
    
    if (_gtdbService.data != null) {
      final gtdbData = _gtdbService.data!;
      
      // Add used cars
      for (final car in gtdbData.usedCars) {
        cars.add(_convertGTDBCarToUnified(car, 'gtdb_used'));
      }
      
      // Add legend cars
      for (final car in gtdbData.legendCars) {
        cars.add(_convertGTDBCarToUnified(car, 'gtdb_legend'));
      }
    }
    
    return cars;
  }

  UnifiedCarData _convertGT7InfoCarToUnified(CarData car, String source) {
    return UnifiedCarData(
      id: car.carId,
      name: car.name,
      shortName: car.name, // GT7Info doesn't have a separate short name
      manufacturer: car.manufacturer,
      region: car.region,
      credits: car.credits,
      state: car.state,
      estimateDays: car.estimateDays,
      maxEstimateDays: car.maxEstimateDays,
      isNew: car.isNew,
      rewardCar: car.rewardCar?.name,
      engineSwap: car.engineSwap?.engineName,
      lotteryCar: car.lotteryCar,
      trophyCar: car.trophyCar,
      source: source,
      imageId: null, // GT7Info doesn't provide image IDs directly
      frontImageId: null,
      sort: null,
    );
  }

  UnifiedCarData _convertGTDBCarToUnified(GTDBCar car, String source) {
    return UnifiedCarData(
      id: car.carId,
      name: car.name ?? 'Unknown Car',
      shortName: car.shortName ?? car.name ?? 'Unknown',
      manufacturer: car.manufacturerName ?? 'Unknown',
      region: 'xx', // GTDB doesn't provide region info
      credits: car.price ?? 0,
      state: car.state ?? 'normal',
      estimateDays: 0, // GTDB doesn't provide estimate days
      maxEstimateDays: 0, // GTDB doesn't provide max estimate days
      isNew: car.isNew,
      rewardCar: null, // GTDB doesn't provide reward car info
      engineSwap: null, // GTDB doesn't provide engine swap info
      lotteryCar: null, // GTDB doesn't provide lottery car info
      trophyCar: null, // GTDB doesn't provide trophy car info
      source: source,
      imageId: car.image,
      frontImageId: car.frontImage,
      sort: car.sort,
    );
  }

  UnifiedCarData _mergeCarData(UnifiedCarData existing, UnifiedCarData newCar) {
    // Prefer information from GT7Info when available, but use GTDB for images
    return UnifiedCarData(
      id: existing.id,
      name: existing.name.isNotEmpty ? existing.name : newCar.name,
      shortName: existing.shortName.isNotEmpty ? existing.shortName : newCar.shortName,
      manufacturer: existing.manufacturer.isNotEmpty ? existing.manufacturer : newCar.manufacturer,
      region: existing.region != 'xx' ? existing.region : newCar.region,
      credits: existing.credits != 0 ? existing.credits : newCar.credits,
      state: existing.state.isNotEmpty ? existing.state : newCar.state,
      estimateDays: existing.estimateDays != 0 ? existing.estimateDays : newCar.estimateDays,
      maxEstimateDays: existing.maxEstimateDays != 0 ? existing.maxEstimateDays : newCar.maxEstimateDays,
      isNew: existing.isNew || newCar.isNew,
      rewardCar: existing.rewardCar ?? newCar.rewardCar,
      engineSwap: existing.engineSwap ?? newCar.engineSwap,
      lotteryCar: existing.lotteryCar ?? newCar.lotteryCar,
      trophyCar: existing.trophyCar ?? newCar.trophyCar,
      source: '${existing.source},${newCar.source}', // Mark as from both sources
      imageId: existing.imageId ?? newCar.imageId, // Prefer GTDB images
      frontImageId: existing.frontImageId ?? newCar.frontImageId,
      sort: existing.sort ?? newCar.sort,
    );
  }

  List<UnifiedCarData> getCarsBySource(String source) {
    return _allCars.where((car) => car.source?.contains(source) ?? false).toList();
  }

  List<UnifiedCarData> getUsedCars() {
    return _allCars.where((car) => 
        car.source?.contains('used') ?? false
    ).toList();
  }

  List<UnifiedCarData> getLegendCars() {
    return _allCars.where((car) => 
        car.source?.contains('legend') ?? false
    ).toList();
  }
}