import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive/breakpoints.dart';
import '../core/theme/fq_colors.dart';
import '../core/theme/fq_gradients.dart';
import '../core/theme/fq_tokens.dart';
import '../core/widgets/fq_background.dart';
import '../core/widgets/fq_buttons.dart';
import '../core/widgets/fq_surface_card.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/learning/state/app_state_providers.dart';
import '../features/profile/presentation/profile_screen.dart';

class QuestShell extends ConsumerStatefulWidget {
  const QuestShell({super.key});

  @override
  ConsumerState<QuestShell> createState() => _QuestShellState();
}

class _QuestShellState extends ConsumerState<QuestShell> {
  int _currentIndex = 0;
  bool _hideBottomNavigation = false;
  bool _welcomeDialogOpen = false;
  OverlayEntry? _topSnackEntry;
  Timer? _topSnackTimer;

  late final List<_TabItem> _tabs = [
    _TabItem(
      label: 'Home',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      screen: HomeScreen(onRouteViewChanged: _onHomeRouteViewChanged),
    ),
    _TabItem(
      label: 'Profile',
      icon: Icons.workspace_premium_outlined,
      selectedIcon: Icons.workspace_premium,
      screen: ProfileScreen(onAfterReset: _goToHomeAfterReset),
    ),
  ];

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

    final progressAsync = ref.watch(appProgressNotifierProvider);
    final progress = progressAsync.valueOrNull;
    if (progress != null) {
      if (_requiresWelcome(progress.userName)) {
        _showWelcomeIfNeeded();
      } else {
        _welcomeDialogOpen = false;
      }
    }

    final isDesktop = FQBreakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: FQBackground(
          child: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: FQSurfaceCard(
                      radius: FQRadius.xLarge,
                      gradient: FQGradients.deepQuest,
                      padding: const EdgeInsets.all(14),
                      shadow: FQShadows.floating,
                      useHighlightOverlay: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flutter Quest',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Learn Dart with focus and momentum',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: NavigationRail(
                              backgroundColor: Colors.transparent,
                              groupAlignment: -0.95,
                              selectedIndex: _currentIndex,
                              onDestinationSelected: _onTabSelected,
                              labelType: NavigationRailLabelType.all,
                              indicatorShape: RoundedRectangleBorder(
                                borderRadius: FQRadius.medium,
                              ),
                              indicatorColor: Colors.white.withValues(
                                alpha: 0.14,
                              ),
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
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.66),
                                  ),
                              destinations: _tabs
                                  .map(
                                    (tab) => NavigationRailDestination(
                                      icon: Icon(tab.icon),
                                      selectedIcon: Icon(tab.selectedIcon),
                                      label: Text(tab.label),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildPageStack()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: FQBackground(child: _buildPageStack()),
      bottomNavigationBar: _currentIndex == 0 && _hideBottomNavigation
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
                          final itemCount = _tabs.length;
                          final itemWidth = constraints.maxWidth / itemCount;
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                left: itemWidth * _currentIndex,
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
                                children: List.generate(_tabs.length, (index) {
                                  final tab = _tabs[index];
                                  final isSelected = _currentIndex == index;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: _BottomNavItem(
                                        tab: tab,
                                        isSelected: isSelected,
                                        onTap: () => _onTabSelected(index),
                                      ),
                                    ),
                                  );
                                }),
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

  Widget _buildPageStack() {
    return IndexedStack(
      index: _currentIndex,
      children: _tabs.map((tab) => tab.screen).toList(),
    );
  }

  void _onTabSelected(int value) {
    setState(() {
      _currentIndex = value;
      if (value != 0) {
        _hideBottomNavigation = false;
      }
    });
  }

  void _onHomeRouteViewChanged(bool isRouteDetail) {
    if (_hideBottomNavigation == isRouteDetail) return;
    setState(() {
      _hideBottomNavigation = isRouteDetail;
    });
  }

  void _goToHomeAfterReset() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
      _hideBottomNavigation = false;
    });
  }

  bool _requiresWelcome(String? userName) {
    return userName == null || userName.trim().isEmpty;
  }

  void _showWelcomeIfNeeded() {
    if (_welcomeDialogOpen || !mounted) return;
    _welcomeDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _WelcomeNameDialog(
            onSubmit: (name) async {
              await ref
                  .read(appProgressNotifierProvider.notifier)
                  .setUserName(name);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          );
        },
      );
      _welcomeDialogOpen = false;
    });
  }

  void _showTopBadgeSnack(BadgeUnlockUiEvent event) {
    _topSnackTimer?.cancel();
    _topSnackEntry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    final topInset = MediaQuery.of(context).padding.top;

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

    overlay.insert(_topSnackEntry!);
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

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final _TabItem tab;
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
            Icon(isSelected ? tab.selectedIcon : tab.icon, color: iconColor),
            const SizedBox(height: 5),
            Text(
              tab.label,
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

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

class _WelcomeNameDialog extends StatefulWidget {
  const _WelcomeNameDialog({required this.onSubmit});

  final Future<void> Function(String name) onSubmit;

  @override
  State<_WelcomeNameDialog> createState() => _WelcomeNameDialogState();
}

class _WelcomeNameDialogState extends State<_WelcomeNameDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: FQSurfaceCard(
        radius: FQRadius.xLarge,
        gradient: FQGradients.subtlePanel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a Flutter Quest',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: FQColors.deepNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Antes de empezar, cuentanos como quieres que te llamemos.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.35),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              enabled: !_saving,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                errorText: _error,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: FQRadius.medium,
                  borderSide: BorderSide(
                    color: FQColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: FQRadius.medium,
                  borderSide: BorderSide(color: FQColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FQPrimaryButton(
                label: _saving ? 'Guardando...' : 'Empezar',
                icon: Icons.arrow_forward_rounded,
                onPressed: _saving ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final cleaned = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) {
      setState(() {
        _error = 'Ingresa un nombre para continuar.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(cleaned);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
