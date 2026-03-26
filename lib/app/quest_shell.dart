import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/responsive/breakpoints.dart';
import '../core/theme/fq_colors.dart';
import '../core/theme/fq_gradients.dart';
import '../core/theme/fq_tokens.dart';
import '../core/widgets/fq_background.dart';
import '../core/widgets/fq_buttons.dart';
import '../core/widgets/fq_surface_card.dart';
import '../features/learning/state/app_state_providers.dart';

class QuestShell extends ConsumerStatefulWidget {
  const QuestShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  ConsumerState<QuestShell> createState() => _QuestShellState();
}

class _QuestShellState extends ConsumerState<QuestShell> {
  bool _welcomeDialogOpen = false;

  @override
  Widget build(BuildContext context) {
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
    final hideBottomNavigation = widget.location.startsWith('/home/route/');

    if (isDesktop) {
      return Scaffold(
        body: FQBackground(
          child: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 122),
                    child: FQSurfaceCard(
                      radius: FQRadius.large,
                      gradient: FQGradients.deepQuest,
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                      shadow: FQShadows.floating,
                      useHighlightOverlay: false,
                      child: NavigationRail(
                        backgroundColor: Colors.transparent,
                        groupAlignment: -0.9,
                        selectedIndex: widget.navigationShell.currentIndex,
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
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.explore_outlined),
                            selectedIcon: Icon(Icons.explore),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.workspace_premium_outlined),
                            selectedIcon: Icon(Icons.workspace_premium),
                            label: Text('Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: widget.navigationShell),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: FQBackground(child: widget.navigationShell),
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
                          const itemCount = 2;
                          final itemWidth = constraints.maxWidth / itemCount;
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                left:
                                    itemWidth *
                                    widget.navigationShell.currentIndex,
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
                                        label: 'Home',
                                        icon: Icons.explore_outlined,
                                        selectedIcon: Icons.explore,
                                        isSelected:
                                            widget
                                                .navigationShell
                                                .currentIndex ==
                                            0,
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
                                        label: 'Profile',
                                        icon: Icons.workspace_premium_outlined,
                                        selectedIcon: Icons.workspace_premium,
                                        isSelected:
                                            widget
                                                .navigationShell
                                                .currentIndex ==
                                            1,
                                        onTap: () => _onTabSelected(1),
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
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _requiresWelcome(String? userName) {
    return userName == null || userName.trim().isEmpty;
  }

  void _showWelcomeIfNeeded() {
    if (_welcomeDialogOpen || !mounted) return;
    _welcomeDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'welcome',
        barrierColor: const Color(0x550A1635),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return _WelcomeNameFullscreen(
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
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      );
      _welcomeDialogOpen = false;
    });
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

class _WelcomeNameFullscreen extends StatefulWidget {
  const _WelcomeNameFullscreen({required this.onSubmit});

  final Future<void> Function(String name) onSubmit;

  @override
  State<_WelcomeNameFullscreen> createState() => _WelcomeNameFullscreenState();
}

class _WelcomeNameFullscreenState extends State<_WelcomeNameFullscreen> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F3FD),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;
            if (!isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: _buildWelcomeContent(context, centered: true),
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/hola_FC.png',
                              width: 380,
                              //height: 380,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                      Expanded(
                        flex: 6,
                        child: _buildWelcomeContent(context, centered: false),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeContent(BuildContext context, {required bool centered}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (centered) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/hola_FC.png',
                width: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          '¡Bienvenido a\nFlutter Quest!',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: FQColors.primary,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu viaje para dominar Dart y Flutter comienza aquí. ¡Prepárate para programar el futuro!',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: FQColors.onSurface.withValues(alpha: 0.76),
            fontSize: 17,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 26),
        FQSurfaceCard(
          radius: FQRadius.xLarge,
          color: Colors.white.withValues(alpha: 0.92),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_rounded,
                color: FQColors.outlineVariant,
              ),
              labelText: 'DANOS TU NOMBRE',
              hintText: 'Tu nombre aquí...',
              filled: false,
              border: InputBorder.none,
              errorText: _error,
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: FQPrimaryButton(
            label: _saving ? 'Guardando...' : 'Empezar',
            icon: Icons.arrow_forward_rounded,
            onPressed: _saving ? null : _submit,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final clean = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) {
      setState(() {
        _error = 'Escribe un nombre para continuar.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await widget.onSubmit(clean);
    if (!mounted) return;
    setState(() {
      _saving = false;
    });
  }
}
