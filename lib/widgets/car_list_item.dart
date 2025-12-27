import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gt7info_data.dart';
import 'package:url_launcher/url_launcher.dart';

class CarListItem extends StatelessWidget {
  final CarData car;
  
  const CarListItem({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with flag, manufacturer, and car name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Country flag
                CachedNetworkImage(
                  imageUrl: car.flagUrl,
                  width: 24,
                  height: 16,
                  errorWidget: (context, url, error) => const Icon(Icons.flag, size: 24),
                ),
                const SizedBox(width: 8),
                
                // Manufacturer and car name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.manufacturer.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchPriceHistory(car.carId),
                        child: Text(
                          car.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Text(
                  'Cr. ${_formatCredits(car.credits)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: car.isSoldOut ? Colors.red : Colors.green[700],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Status row
            Row(
              children: [
                // NEW indicator if applicable
                if (car.isNew) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Status text (sold out, limited stock, available days)
                Expanded(
                  child: Text(
                    car.statusText,
                    style: TextStyle(
                      fontWeight: car.isSoldOut || car.isLimitedStock
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: car.isSoldOut
                          ? Colors.red
                          : car.isLimitedStock
                              ? Colors.orange[800]
                              : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            
            // Special attributes (reward car, engine swap, etc.)
            if (car.hasSpecialAttributes) ...[
              const SizedBox(height: 12),
              
              // Wrap the attributes in a flexible layout
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Reward car
                  if (car.rewardCar != null)
                    _buildAttributeBadge(
                      context,
                      'REWARD CAR',
                      car.rewardCar!.rewardText,
                      Icons.card_giftcard,
                    ),
                    
                  // Engine swap
                  if (car.engineSwap != null)
                    _buildAttributeBadge(
                      context,
                      'ENGINE SWAP',
                      car.engineSwap!.swapInfoText,
                      Icons.settings,
                    ),
                    
                  // Lottery car
                  if (car.lotteryCar != null)
                    _buildAttributeBadge(
                      context,
                      'TICKET REWARD',
                      'Can be won from tickets',
                      Icons.card_giftcard,
                    ),
                    
                  // Trophy car
                  if (car.trophyCar != null)
                    _buildAttributeBadge(
                      context,
                      'TROPHY REQ.',
                      'Must be owned to earn the ${car.trophyCar} trophy',
                      Icons.emoji_events,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttributeBadge(BuildContext context, String title, String tooltip, IconData icon) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.blue[700]),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatCredits(int credits) {
    final formatted = credits.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},'
    );
    return formatted;
  }
  
  Future<void> _launchPriceHistory(String carId) async {
    final url = 'https://ddm999.github.io/gt7info/cars/prices_$carId.png';
    
    try {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}