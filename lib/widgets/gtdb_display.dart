import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gtdb_data.dart';
import '../models/gt7info_data.dart'; // Needed for CarData compatibility
import '../services/gtdb_service.dart';
import '../widgets/car_grid_item.dart';

class GTDBDisplay extends StatefulWidget {
  const GTDBDisplay({super.key});

  @override
  State<GTDBDisplay> createState() => _GTDBDisplayState();
}

class _GTDBDisplayState extends State<GTDBDisplay> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch GTDB data when widget initializes
    Future.microtask(() {
      context.read<GTDBService>().fetchGTDBData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GTDBService>(
      builder: (context, service, child) {
        if (service.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (service.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error Loading GTDB Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  service.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => service.fetchGTDBData(forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (service.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No GTDB data available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => service.fetchGTDBData(forceRefresh: true),
                  child: const Text('Load Data'),
                ),
              ],
            ),
          );
        }

        final data = service.data!;
        final lastUpdated = service.lastUpdated;

        return Column(
          children: [
            // Header with last updated info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GTDB Dealership Info',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (lastUpdated != null)
                              Text(
                                'Last refreshed: ${_formatDateTime(lastUpdated)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh data',
                        onPressed: () => service.fetchGTDBData(forceRefresh: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Used Car Dealership'),
                Tab(text: 'Legendary Dealership'),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Used cars tab
                  _buildCarListView(data.usedCars, 'GTDB Used Cars'),

                  // Legendary cars tab
                  _buildCarListView(data.legendCars, 'GTDB Legendary Cars'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarListView(List<GTDBCar> cars, String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double itemWidth = 300.0; // Approximate width for each item
              
              // For used car dealership, return 4-6 items per row depending on screen size
              if (title.contains('Used Cars')) {
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1; // 1 item per row on small screens
                } else if (constraints.maxWidth < 800) {
                  crossAxisCount = 2; // 2 items per row on medium screens
                } else if (constraints.maxWidth < 1200) {
                  crossAxisCount = 4; // 4 items per row on larger screens
                } else {
                  crossAxisCount = 6; // 6 items per row on very large screens
                }
              } else {
                // For legendary cars, use a consistent grid
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1; // 1 item per row on small screens
                } else if (constraints.maxWidth < 800) {
                  crossAxisCount = 2; // 2 items per row on medium screens
                } else {
                  crossAxisCount = 3; // 3 items per row on larger screens
                }
              }
              
              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5, // Adjust aspect ratio as needed
                ),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  return CarGridItem(car: _convertToCarData(cars[index])); // Convert GTDBCar to CarData for compatibility
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Convert GTDBCar to CarData for compatibility with CarGridItem widget
  CarData _convertToCarData(GTDBCar gtdbCar) {
    return gtdbCar.toCarData();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}