import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/unified_car_repository.dart';
import 'services/telemetry_service.dart';
import 'services/gt7info_service.dart';
import 'services/gtdb_service.dart';
import 'pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TelemetryService()),
        ChangeNotifierProvider(create: (context) => GT7InfoService()),
        ChangeNotifierProvider(create: (context) => GTDBService()),
        ChangeNotifierProxyProvider2<
            GT7InfoService,
            GTDBService,
            UnifiedCarRepository
        >(
          create: (context) => UnifiedCarRepository(
            Provider.of<GT7InfoService>(context, listen: false),
            Provider.of<GTDBService>(context, listen: false),
          ),
          update: (context, gt7InfoService, gtdbService, repository) {
            return repository ??
                UnifiedCarRepository(gt7InfoService, gtdbService);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Gran Turismo 7 Companion',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}