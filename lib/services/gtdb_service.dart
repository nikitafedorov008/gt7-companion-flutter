import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/gtdb_data.dart';

class GTDBService extends ChangeNotifier {
  static const String _playstationDbApi = 'https://api.playstationdb.com/graphql';

  // Bearer token extracted from the curl command
  static const String _bearerToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJodHRwczovL2hhc3VyYS5pby9qd3QvY2xhaW1zIjp7IngtaGFzdXJhLWRlZmF1bHQtcm9sZSI6InVzZXIiLCJ4LWhhc3VyYS1hbGxvd2VkLXJvbGVzIjpbInVzZXIiXSwieC1oYXN1cmEtdXNlci1pZCI6IjFlNmNhMjhmLTY4YTQtNDg3NS1iZDBjLTIwMDg0M2MxNWQwNSJ9LCJleHAiOjE3Njc0OTc4MjAsImlhdCI6MTc2Njg5MzAyMH0.kOyQlc4JGKfffg-h-BrT3fzocjSSX020QivBGaDa5SY';

  GTDBData? _data;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  GTDBData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // Headers for API requests
  static Map<String, String> get _headers {
    return {
      'accept': 'application/graphql-response+json, application/graphql+json, application/json, text/event-stream, multipart/mixed',
      'accept-language': 'ru-RU,ru;q=0.9,en-GB;q=0.8,en;q=0.7,ja-JP;q=0.6,ja;q=0.5,en-US;q=0.4',
      'authorization': 'Bearer $_bearerToken',
      'content-type': 'application/json',
      'dnt': '1',
    };
  }

  Future<void> fetchGTDBData({bool forceRefresh = false}) async {
    if (_isLoading) return;

    // Skip if data already loaded and not force refreshing
    if (!forceRefresh && _data != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch both used and legendary cars data
      final usedCarsData = await _fetchUsedCarDealership();
      final legendCarsData = await _fetchLegendaryDealership();

      if (usedCarsData != null && legendCarsData != null) {
        // Parse both datasets
        final usedCars = <GTDBCar>[];
        final legendCars = <GTDBCar>[];

        // Parse used cars if available
        if (usedCarsData['data'] != null && usedCarsData['data']['gt_car'] != null) {
          final usedCarList = usedCarsData['data']['gt_car'] as List;
          usedCars.addAll(usedCarList.map((car) => GTDBCar.fromUsedCarJson(car)).toList());
        }

        // Parse legend cars if available
        if (legendCarsData['data'] != null && legendCarsData['data']['gt_car'] != null) {
          final legendCarList = legendCarsData['data']['gt_car'] as List;
          legendCars.addAll(legendCarList.map((car) => GTDBCar.fromLegendCarJson(car)).toList());
        }

        _data = GTDBData(
          usedCars: usedCars,
          legendCars: legendCars,
        );
        _lastUpdated = DateTime.now();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load complete GTDB data';
      }
    } catch (e) {
      _errorMessage = 'Error loading GTDB data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch used car dealership data
  Future<Map<String, dynamic>?> _fetchUsedCarDealership() async {
    try {
      final response = await http.post(
        Uri.parse(_playstationDbApi),
        headers: _headers,
        body: jsonEncode({
          "operationName": "AllUsedCars",
          "query": "query AllUsedCars {\n  gt_car(where: {details: {_has_key: \n\"in_ucd\"}}, order_by: {updated_at: desc}) {\n    id\n    details\n    manufacturer {\n      name\n      __typename\n    }\n    name\n    short_name\n    slug\n    updated_at\n    __typename\n  }\n}",
          "variables": {}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint('Failed to load used car dealership data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching used car dealership data: $e');
      return null;
    }
  }

  // Fetch legendary dealership data
  Future<Map<String, dynamic>?> _fetchLegendaryDealership() async {
    try {
      // Using the same API endpoint as used cars but with different query for legend cars
      final response = await http.post(
        Uri.parse(_playstationDbApi),
        headers: _headers,
        body: jsonEncode({
          "operationName": "LegendCars",
          "query": "query LegendCars {\n  gt_car(where: {details: {_has_key: \"in_legend\"}}, order_by: {updated_at: desc}) {\n    id\n    sort\n    state\n    price\n    image\n    frontImage\n    manufacturer {\n      name\n    }\n    name\n    short_name\n    slug\n    updated_at\n  }\n}",
          "variables": {}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint('Failed to load legendary dealership data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching legendary dealership data: $e');
      return null;
    }
  }
}