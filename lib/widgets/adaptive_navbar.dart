import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../router/app_router.dart';

/// Adaptive navigation bar used across the app.
/// - Desktop / Web: renders a top navigation bar.
/// - Mobile (iOS/Android): renders a bottom navigation bar with a centered circular button.
class AdaptiveNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveNavBar({super.key});

  bool get _isMobile {
    if (kIsWeb) return false;
    final p = defaultTargetPlatform;
    return p == TargetPlatform.iOS || p == TargetPlatform.android;
  }

  void _goHome(BuildContext context) {
    // Prefer tab switching when we're inside a TabsRouter; fallback to push/pop.
    TabsRouter? tabs;
    try {
      tabs = AutoTabsRouter.of(context);
    } catch (_) {
      tabs = null;
    }
    if (tabs != null) {
      tabs.setActiveIndex(0);
      return;
    }

    final router = context.router;
    bool foundHome = false;
    router.popUntil((r) {
      if (r.settings.name == '/home') foundHome = true;
      return r.isFirst || foundHome;
    });
    if (!foundHome) router.push(const HomePageRoute());
  }

  void _openPlaceholder(BuildContext context, String title) {
    TabsRouter? tabs;
    try {
      tabs = AutoTabsRouter.of(context);
    } catch (_) {
      tabs = null;
    }

    // Map placeholder buttons to tab indexes when possible.
    if (tabs != null) {
      if (title == 'Wishlist') {
        tabs.setActiveIndex(1);
        return;
      }
      if (title == 'Profile') {
        tabs.setActiveIndex(2);
        return;
      }
      // fallback -> open home
      tabs.setActiveIndex(0);
      return;
    }

    // If no TabsRouter present, preserve previous push behavior (legacy).
    final router = context.router;
    if (title == 'Screen A') {
      router.push(const ScreenARoute());
    } else if (title == 'Screen B') {
      router.push(const ScreenBRoute());
    } else {
      router.push(const ScreenARoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    if (_isMobile) {
      // Bottom navigation with centered circular button. When inside a
      // TabsRouter, reflect and control the active index.
      TabsRouter? tabs;
      try {
        tabs = AutoTabsRouter.of(context);
      } catch (_) {
        tabs = null;
      }
      final active = tabs?.activeIndex ?? -1;

      return SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // background bar
            Positioned.fill(
              bottom: 12,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // left button -> Wishlist tab (index 1)
                      IconButton(
                        onPressed: () => _openPlaceholder(context, 'Wishlist'),
                        icon: Icon(
                          Icons.favorite_border,
                          color: active == 1
                              ? Colors.pinkAccent
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 56), // spacer for central button
                      // right button -> Profile tab (index 2)
                      IconButton(
                        onPressed: () => _openPlaceholder(context, 'Profile'),
                        icon: Icon(
                          Icons.person_outline,
                          color: active == 2
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // central circular button (overlaps bar)
            Positioned(
              bottom: 20,
              child: GestureDetector(
                onTap: () => _goHome(context),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: active == 0
                          ? [primary, primary.withOpacity(0.85)]
                          : [
                              primary.withOpacity(0.12),
                              primary.withOpacity(0.08),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/gran_turismo_logotype.svg',
                      color: active == 0
                          ? onPrimary
                          : Theme.of(context).iconTheme.color,
                      height: 32,
                      width:  32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop / Web — top navigation bar
    TabsRouter? tabs;
    try {
      tabs = AutoTabsRouter.of(context);
    } catch (_) {
      tabs = null;
    }
    final active = tabs?.activeIndex ?? -1;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.04),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
          ),
        ),
      ),
      child: Row(
        children: [
          // circular home button on the left
          InkWell(
            onTap: () => _goHome(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active == 0
                    ? primary.withOpacity(0.12)
                    : primary.withOpacity(0.04),
              ),
              child: Icon(
                Icons.home,
                color: active == 0
                    ? primary
                    : Theme.of(context).iconTheme.color,
              ),
            ),
          ),

          const SizedBox(width: 18),
          // app title / spacer
          Text('GT7 Companion', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),

          // two action buttons on the right (map to tabs when available)
          TextButton.icon(
            onPressed: () => _openPlaceholder(context, 'Wishlist'),
            icon: Icon(
              Icons.favorite_border,
              color: active == 1
                  ? Colors.pinkAccent
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
            label: const Text('Wishlist'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _openPlaceholder(context, 'Profile'),
            icon: Icon(
              Icons.person_outline,
              color: active == 2
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
            label: const Text('Profile'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
