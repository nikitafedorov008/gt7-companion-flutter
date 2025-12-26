import 'package:flutter/material.dart';
import '../services/network_scanner.dart';

class PlayStationScannerDialog extends StatefulWidget {
  const PlayStationScannerDialog({super.key});

  @override
  State<PlayStationScannerDialog> createState() => _PlayStationScannerDialogState();
}

class _PlayStationScannerDialogState extends State<PlayStationScannerDialog> {
  List<PlayStationDevice> _devices = [];
  bool _isScanning = false;
  bool _isDeepScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _quickScan();
  }

  Future<void> _quickScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _devices = [];
    });

    try {
      final devices = await NetworkScanner.scanForPlayStations();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Scan failed: $e';
        _isScanning = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Find PlayStation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isScanning || _isDeepScanning ? null : _quickScan,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Quick Scan (ARP)'),
                ),
                const SizedBox(width: 8),
                // ElevatedButton.icon(
                //   onPressed: _isScanning || _isDeepScanning ? null : _deepScan,
                //   icon: const Icon(Icons.search, size: 18),
                //   label: const Text('Deep Scan (Ping)'),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isDeepScanning 
                  ? 'Deep scanning network (this may take 10-30 seconds)...'
                  : 'Scanning local network for PlayStation devices...',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isScanning || _isDeepScanning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Scanning network...'),
                    ],
                  ),
                ),
              ),
            if (!_isScanning && !_isDeepScanning && _devices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No devices found',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Make sure your PlayStation is on and connected to the same network',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            if (_devices.isNotEmpty)
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        leading: Icon(
                          device.isLikelyPlayStation
                              ? Icons.sports_esports
                              : Icons.device_unknown,
                          color: device.isLikelyPlayStation
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        title: Text(
                          device.ipAddress,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (device.macAddress != 'Unknown')
                              Text(
                                device.macAddress,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    device.vendor,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: device.isLikelyPlayStation
                                          ? Colors.green.shade700
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${device.confidence}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: device.isLikelyPlayStation
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PlayStation',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop(device.ipAddress);
                        },
                      );
                    },
                  ),
                ),
              ),
            if (_devices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Found ${_devices.length} device(s). Tap to select.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
