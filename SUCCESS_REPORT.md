# GT7Info Feature Implementation

## Feature Overview
The GT7Info feature allows users to browse real-time data about available cars in Gran Turismo 7's dealerships. This data is fetched from the official GT7Info API and presented in a user-friendly interface that matches the styling of the original website.

## Implementation Details

### New Dependencies Added
- `http: ^1.2.0` - For making API requests
- `cached_network_image: ^3.3.1` - For efficiently loading and caching images (flags, icons)
- `url_launcher: ^6.2.4` - For opening external links (price history graphs)

### New Files Created

#### Models
- `gt7info_data.dart` - Model classes for the GT7Info API data, including:
  - `GT7InfoData` - Top-level data container
  - `UsedCarData` & `LegendCarData` - Dealership-specific data
  - `CarData` - Individual car information
  - `RewardCarData` & `EngineSwapData` - Special car attributes

#### Services
- `gt7info_service.dart` - Service for fetching and managing the GT7Info API data:
  - Handles API requests and error handling
  - Manages data caching and refresh operations
  - Provides state management for loading and error states

#### Widgets
- `gt7info_display.dart` - Main display widget for the GT7Info data:
  - Implements a tabbed interface for Used and Legendary cars
  - Shows loading/error states
  - Displays metadata about the last update
- `car_list_item.dart` - Widget for displaying individual car information:
  - Includes car details (manufacturer, name, price, etc.)
  - Shows special indicators (NEW, SOLD OUT, etc.)
  - Displays badges for special attributes (engine swaps, rewards, etc.)
  - Links to price history graphs

### Application Integration
- Updated `main.dart` to:
  - Add the GT7Info service to the provider system
  - Create a tabbed interface to switch between telemetry and GT7Info
  - Set up the necessary widget hierarchy

### Features Implemented
1. Fetching and displaying real-time data from the GT7Info API
2. Tabbed interface for Used and Legendary car dealerships
3. Detailed car information with pricing and availability
4. Special indicators for new cars, limited stock, and sold out
5. Badges for special car attributes (rewards, engine swaps, etc.)
6. Support for opening price history graphs
7. Proper error handling and refresh functionality
8. Responsive design for various screen sizes

## User Experience
Users can now:
- Browse all cars currently available in the GT7 dealerships
- See detailed information about each car, including price and availability
- Identify special cars (rewards, engine swaps, etc.)
- Track when cars will be removed from dealerships
- Open price history graphs to see how car prices have changed over time

## Future Enhancements
Possible future enhancements could include:
- Offline mode with cached dealership data
- Notifications for when favorite cars become available
- Filtering and sorting options for car lists
- Deeper integration with the telemetry data
- Adding the "Daily Races" information section