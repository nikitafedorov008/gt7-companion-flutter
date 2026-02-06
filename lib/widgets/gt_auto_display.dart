import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GTAutoDisplay extends StatelessWidget {
  const GTAutoDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      body: const Center(child: Text('Coming soon')),
    );
  }
}
