import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/fq_gradients.dart';
import '../core/theme/fq_tokens.dart';
import '../core/widgets/fq_surface_card.dart';
import '../features/learning/state/app_state_providers.dart';
import 'app_router.dart';

class GlobalBadgeOverlayHost extends ConsumerStatefulWidget {
  const GlobalBadgeOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GlobalBadgeOverlayHost> createState() =>
      _GlobalBadgeOverlayHostState();
}

class _GlobalBadgeOverlayHostState
    extends ConsumerState<GlobalBadgeOverlayHost> {
  OverlayEntry? _topSnackEntry;
  Timer? _topSnackTimer;

  @override
  Widget build(BuildContext context) {
    ref.listen<List<BadgeUnlockUiEvent>>(badgeUiEventQueueProvider, (
      previous,
      next,
    ) {
      if (!mounted || next.isEmpty) return;
      final event = next.first;
      ref.read(badgeUiEventQueueProvider.notifier).consumeFirst();
      _showTopBadgeSnack(event);
    });
    return widget.child;
  }

  void _showTopBadgeSnack(BadgeUnlockUiEvent event) {
    _topSnackTimer?.cancel();
    _topSnackEntry?.remove();

    final overlayState = rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showTopBadgeSnack(event);
      });
      return;
    }

    final navigatorContext = rootNavigatorKey.currentContext;
    final topInset = navigatorContext == null
        ? 0.0
        : MediaQuery.of(navigatorContext).padding.top;

    _topSnackEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topInset + 10,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FQSurfaceCard(
                    radius: FQRadius.large,
                    gradient: FQGradients.primaryCta,
                    useHighlightOverlay: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shadow: FQShadows.floating,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: Icon(event.icon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Nueva insignia desbloqueada',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                              ),
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(_topSnackEntry!);
    _topSnackTimer = Timer(const Duration(milliseconds: 2600), () {
      _topSnackEntry?.remove();
      _topSnackEntry = null;
    });
  }

  @override
  void dispose() {
    _topSnackTimer?.cancel();
    _topSnackEntry?.remove();
    super.dispose();
  }
}
