import 'package:flutter/material.dart';
import 'package:gt7_telemetry_flutter/widgets/gtdb_display.dart';
import 'package:provider/provider.dart';
import 'repositories/unified_car_repository.dart';
import 'services/telemetry_service.dart';
import 'services/gt7info_service.dart';
import 'services/gtdb_service.dart';
import 'widgets/telemetry_display.dart';
import 'widgets/playstation_scanner_dialog.dart';
import 'widgets/unified_car_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TelemetryService()),
        ChangeNotifierProvider(create: (context) => GT7InfoService()),
        ChangeNotifierProvider(create: (context) => GTDBService()),
        ChangeNotifierProxyProvider2<GT7InfoService, GTDBService, UnifiedCarRepository>(
          create: (context) => UnifiedCarRepository(
            Provider.of<GT7InfoService>(context, listen: false),
            Provider.of<GTDBService>(context, listen: false),
          ),
          update: (context, gt7InfoService, gtdbService, repository) {
            return repository ?? UnifiedCarRepository(gt7InfoService, gtdbService);
          },
        ),
      ],
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

class _TelemetryScreenState extends State<TelemetryScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  List<Widget> _buildConnectionControls(bool isDesktop) {
    if (isDesktop) {
      // Для десктопного режима - горизонтальный layout
      return [
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
        const SizedBox(width: 16),
        SizedBox(
          width: 240, // фиксированная ширина для кнопок
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isConnecting
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            _isConnecting = true;
                          });
                          await Provider.of<TelemetryService>(context, listen: false)
                              .connectToGT7(_ipController.text);
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Consumer<TelemetryService>(
                builder: (context, service, _) => ElevatedButton(
                  onPressed: service.isConnected ? () => service.disconnect() : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Disconnect'),
                ),
              ),
            ),
          ]),
        ),
      ];
    } else {
      // Для мобильного режима - вертикальный layout
      return [
        TextFormField(
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
            final ipPattern = RegExp(
              r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
            );
            if (!ipPattern.hasMatch(value)) {
              return 'Please enter a valid IP address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isConnecting
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          _isConnecting = true;
                        });
                        await Provider.of<TelemetryService>(context, listen: false)
                            .connectToGT7(_ipController.text);
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
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Consumer<TelemetryService>(
              builder: (context, service, _) => ElevatedButton(
                onPressed: service.isConnected ? () => service.disconnect() : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Disconnect'),
              ),
            ),
          ),
        ]),
      ];
    }
  }
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _ipController.text = '192.168.1.123'; // Default IP, user should change this
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GT7 Companion Flutter'),
        bottom: TabBar(
          controller: _mainTabController,
          tabs: const [
            Tab(text: 'Telemetry'),
            Tab(text: 'Dealerships'),
          ],
        ),
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
      body: TabBarView(
        controller: _mainTabController,
        children: [
          // Telemetry Tab
          Consumer<TelemetryService>(
            builder: (context, service, child) {
              return Column(
            children: [
              // Connection form
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: isDesktop ? Row(
                    children: _buildConnectionControls(isDesktop),
                  ) : Column(
                    children: _buildConnectionControls(isDesktop),
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
          
          // GT7 Info Tab
          //const GT7InfoDisplay(),
          //const GTDBDisplay(),
          UnifiedCarDisplay(),
        ],
      ),
    );
  }
}
