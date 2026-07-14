import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/responsive/breakpoints.dart';
import '../core/theme/fq_colors.dart';
import '../core/theme/fq_gradients.dart';
import '../core/theme/fq_tokens.dart';
import '../core/widgets/fq_background.dart';
import '../core/widgets/fq_surface_card.dart';

class QuestShell extends StatelessWidget {
  const QuestShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = FQBreakpoints.isDesktop(context);
    final hideBottomNavigation =
        location.startsWith('/home/route/') ||
        location.startsWith('/challenges/play');

    if (isDesktop) {
      return Scaffold(
        body: FQBackground(
          child: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 132),
                    child: FQSurfaceCard(
                      radius: FQRadius.large,
                      gradient: FQGradients.deepQuest,
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                      shadow: FQShadows.floating,
                      useHighlightOverlay: false,
                      child: NavigationRail(
                        backgroundColor: Colors.transparent,
                        groupAlignment: -0.9,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: _onTabSelected,
                        labelType: NavigationRailLabelType.all,
                        useIndicator: true,
                        minWidth: 96,
                        minExtendedWidth: 116,
                        indicatorShape: RoundedRectangleBorder(
                          borderRadius: FQRadius.medium,
                        ),
                        indicatorColor: Colors.white.withValues(alpha: 0.16),
                        selectedIconTheme: const IconThemeData(
                          color: Colors.white,
                          size: 22,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: Colors.white.withValues(alpha: 0.66),
                          size: 21,
                        ),
                        selectedLabelTextStyle: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                        unselectedLabelTextStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.explore_outlined),
                            selectedIcon: const Icon(Icons.explore),
                            label: Text(l10n.homeTab),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.bolt_outlined),
                            selectedIcon: const Icon(Icons.bolt_rounded),
                            label: Text(l10n.challengesTab),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.workspace_premium_outlined),
                            selectedIcon: const Icon(Icons.workspace_premium),
                            label: Text(l10n.profileTab),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: FQBackground(child: navigationShell),
      bottomNavigationBar: hideBottomNavigation
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: ClipRRect(
                borderRadius: FQRadius.xLarge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.86),
                          FQColors.surfaceHigh.withValues(alpha: 0.82),
                        ],
                      ),
                      borderRadius: FQRadius.xLarge,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.76),
                        width: 1.3,
                      ),
                      boxShadow: FQShadows.soft,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const itemCount = 3;
                          final itemWidth = constraints.maxWidth / itemCount;
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                left: itemWidth * navigationShell.currentIndex,
                                top: 0,
                                bottom: 0,
                                width: itemWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: FQGradients.primaryCta,
                                      borderRadius: FQRadius.large,
                                      boxShadow: FQShadows.glow,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: _BottomNavItem(
                                        label: l10n.homeTab,
                                        icon: Icons.explore_outlined,
                                        selectedIcon: Icons.explore,
                                        isSelected:
                                            navigationShell.currentIndex == 0,
                                        onTap: () => _onTabSelected(0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: _BottomNavItem(
                                        label: l10n.challengesTab,
                                        icon: Icons.bolt_outlined,
                                        selectedIcon: Icons.bolt_rounded,
                                        isSelected:
                                            navigationShell.currentIndex == 1,
                                        onTap: () => _onTabSelected(1),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: _BottomNavItem(
                                        label: l10n.profileTab,
                                        icon: Icons.workspace_premium_outlined,
                                        selectedIcon: Icons.workspace_premium,
                                        isSelected:
                                            navigationShell.currentIndex == 2,
                                        onTap: () => _onTabSelected(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected
        ? Colors.white
        : FQColors.onSurface.withValues(alpha: 0.7);
    return InkWell(
      borderRadius: FQRadius.large,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: iconColor),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: iconColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
