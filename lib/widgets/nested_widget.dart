import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

import 'adaptive_navbar.dart';

/// Shell that uses AutoRoute's tabbed API (pageView) so child pages can be
/// swiped and the TabsRouter is available to the `AdaptiveNavBar`.
@RoutePage()
class NestedWidget extends StatelessWidget {
  const NestedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.pageView(
      // primary app sections exposed as tabs
      routes: const [
        HomePageRoute(),
        UsedCarDisplayRoute(),
        LegendaryCarDisplayRoute(),
        TelemetryDetailsScreenRoute(),
      ],
      builder: (context, child, _) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(72),
                  child: AdaptiveNavBar(),
                )
              : null,
          bottomNavigationBar: isDesktop ? null : const AdaptiveNavBar(),
          body: SafeArea(child: child),
        );
      },
    );
  }
}
