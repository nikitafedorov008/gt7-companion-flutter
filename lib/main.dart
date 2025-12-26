import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/telemetry_service.dart';
import 'widgets/telemetry_display.dart';
import 'widgets/playstation_scanner_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TelemetryService(),
      child: MaterialApp(
        title: 'GT7 Telemetry Flutter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TelemetryScreen(),
      ),
    );
  }
}

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _ipController.text = '192.168.1.123'; // Default IP, user should change this
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GT7 Telemetry Flutter'),
        actions: [
          Consumer<TelemetryService>(
            builder: (context, service, child) {
              return IconButton(
                icon: Icon(
                  service.isConnected ? Icons.link : Icons.link_off,
                  color: service.isConnected ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  if (service.isConnected) {
                    service.disconnect();
                  }
                },
                tooltip: service.isConnected ? 'Disconnect' : 'Not Connected',
              );
            },
          ),
        ],
      ),
      body: Consumer<TelemetryService>(
        builder: (context, service, child) {
          return Column(
            children: [
              // Connection form
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ipController,
                          decoration: InputDecoration(
                            labelText: 'PlayStation IP Address',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: 'Scan for PlayStation',
                              onPressed: () async {
                                final selectedIp = await showDialog<String>(
                                  context: context,
                                  builder: (context) => const PlayStationScannerDialog(),
                                );
                                if (selectedIp != null) {
                                  _ipController.text = selectedIp;
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an IP address';
                            }
                            // Basic IP validation
                            final ipPattern = RegExp(
                              r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
                            );
                            if (!ipPattern.hasMatch(value)) {
                              return 'Please enter a valid IP address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isConnecting
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() {
                                    _isConnecting = true;
                                  });
                                  await service.connectToGT7(_ipController.text);
                                  setState(() {
                                    _isConnecting = false;
                                  });
                                }
                              },
                        child: _isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Connect'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: service.isConnected ? () => service.disconnect() : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Disconnect'),
                      ),
                    ],
                  ),
                ),
              ),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: service.isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: service.isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (service.errorMessage != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Error: ${service.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Telemetry display
              Expanded(
                child: TelemetryDisplay(
                  telemetry: service.telemetry,
                  errorMessage: service.errorMessage,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
