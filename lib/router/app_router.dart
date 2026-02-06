import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../pages/gt_auto_display.dart';
import '../pages/home_page.dart';
import '../widgets/nested_widget.dart';
import '../widgets/used_car_display.dart';
import '../widgets/legendary_car_display.dart';
import '../widgets/gt_auto_display.dart' hide GTAutoDisplay;
import '../widgets/home_shell.dart';
import '../pages/profile_page.dart';
import '../pages/wishlist_page.dart';
import '../pages/empty_screen.dart';
import '../widgets/telemetry_display.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRouteGuard> get guards => [];

  @override
  List<AutoRoute> get routes => [
    // ShellRoute provides the app shell (nav bar, scaffold) and an inner
    // AutoRouter for the shell's children. This matches the AutoRoute
    // nested-navigation pattern from the docs.
    AutoRoute(
      page: NestedWidgetRoute.page,
      initial: true,
      children: [
        // `HomeShell` hosts the Home screen and its in-place children so that
        // Used / Legendary / GT Auto open inside the Home area.
        AutoRoute(
          page: HomeShellRoute.page,
          initial: true,
          path: 'home',
          children: [
            AutoRoute(page: HomePageRoute.page, initial: true, path: ''),
            AutoRoute(page: UsedCarDisplayRoute.page, path: 'used'),
            AutoRoute(page: LegendaryCarDisplayRoute.page, path: 'legendary'),
            AutoRoute(page: GTAutoDisplayRoute.page, path: 'gtauto'),
          ],
        ),

        // top-level tabs (wishlist/profile) remain on the main shell
        AutoRoute(page: WishlistPageRoute.page, path: 'wishlist'),
        AutoRoute(page: ProfilePageRoute.page, path: 'profile'),
        AutoRoute(page: TelemetryDetailsScreenRoute.page, path: 'telemetry'),

        // simple placeholder screens
        AutoRoute(page: ScreenARoute.page, path: 'a'),
        AutoRoute(page: ScreenBRoute.page, path: 'b'),
      ],
    ),

    // (now reachable as children of `HomeShell`) — remove duplicate top-level entries.
  ];
}
