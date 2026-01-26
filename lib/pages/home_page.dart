import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/telemetry_service.dart';
import '../widgets/gt_auto_display.dart';
import '../widgets/legendary_car_display.dart';
import '../widgets/playstation_scanner_dialog.dart';
import '../widgets/telemetry_display.dart';
import '../widgets/used_car_display.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _ipController.text = '192.168.1.123';
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _openTelemetry(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TelemetryDetailsScreen()));
  }

  void _openUsedCarDealer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UsedCarDisplay(),
      ),
    );
  }

  void _openLegendaryCarDealer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegendaryCarDisplay(),
      ),
    );
  }

  void _openGTAuto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('GT Auto')),
          body: const GTAutoDisplay(),
        ),
      ),
    );
  }

  Widget _buildConnectionForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'PlayStation IP',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
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
                      return 'Enter IP';
                    }
                    final ipPattern = RegExp(
                      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
                    );
                    if (!ipPattern.hasMatch(value)) {
                      return 'Invalid IP';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56, // Match input height roughly
                child: Consumer<TelemetryService>(
                  builder: (context, service, _) {
                    if (service.isConnected) {
                      return ElevatedButton(
                        onPressed: () => service.disconnect(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Disconnect'),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: _isConnecting
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() {
                                    _isConnecting = true;
                                  });
                                  await Provider.of<TelemetryService>(
                                    context,
                                    listen: false,
                                  ).connectToGT7(_ipController.text);
                                  setState(() {
                                    _isConnecting = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                        child: _isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Connect'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<TelemetryService>(
            builder: (context, service, _) {
              if (service.isConnected) {
                 return Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text(
                       'Status: Connected',
                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                     ),
                     TextButton.icon(
                       onPressed: () => _openTelemetry(context),
                       icon: const Icon(Icons.open_in_new, color: Colors.white),
                       label: const Text('Open Dashboard', style: TextStyle(color: Colors.white)),
                     )
                   ],
                 );
              } else if (service.errorMessage != null) {
                return Text(
                  'Error: ${service.errorMessage}',
                  style: const TextStyle(color: Colors.redAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Gran Turismo 7 Companion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telemetry',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConnectionForm(isDesktop),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Apps', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 2;
                if (width > 600) crossAxisCount = 3;
                if (width > 900) crossAxisCount = 4;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _AppTile(
                      icon: Icons.storefront,
                      label: 'Used car dealer',
                      onTap: () => _openUsedCarDealer(context),
                    ),
                    _AppTile(
                      icon: Icons.star,
                      label: 'Legendary car dealer',
                      onTap: () => _openLegendaryCarDealer(context),
                    ),
                    _AppTile(
                      icon: Icons.build,
                      label: 'GT Auto',
                      onTap: () => _openGTAuto(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AppTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelemetryDetailsScreen extends StatelessWidget {
  const TelemetryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Telemetry Dashboard'),
      ),
      body: Consumer<TelemetryService>(
        builder: (context, service, child) {
          if (!service.isConnected) {
            return const Center(
              child: Text('Not connected to GT7'),
            );
          }
          return Column(
            children: [
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
