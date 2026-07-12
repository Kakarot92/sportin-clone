import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'home.dart';
import 'measurements.dart';
import 'messages.dart';
import 'profile.dart';
import 'trainers.dart';

/// Glavni shell — 5 tabova sa kinetičkom donjom navigacijom.
/// Svaki prelaz taba ponovo režira ulaznu koreografiju ekrana.
class StudioAShell extends StatefulWidget {
  const StudioAShell({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  State<StudioAShell> createState() => _StudioAShellState();
}

class _StudioAShellState extends State<StudioAShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.bolt_rounded, label: 'POČETNA'),
    (icon: Icons.event_rounded, label: 'TERMINI'),
    (icon: Icons.ssid_chart_rounded, label: 'MERENJA'),
    (icon: Icons.forum_rounded, label: 'PORUKE'),
    (icon: Icons.person_rounded, label: 'PROFIL'),
  ];

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_index) {
      0 => StudioAHomeScreen(key: const ValueKey(0), onQuickNav: _go),
      1 => const StudioATrainersScreen(key: ValueKey(1)),
      2 => const StudioAMeasurementsScreen(key: ValueKey(2)),
      3 => const StudioAMessagesScreen(key: ValueKey(3)),
      _ => StudioAProfileScreen(key: const ValueKey(4), onExit: widget.onExit),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 340),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        child: screen,
      ),
      bottomNavigationBar: _KineticNavBar(
        tabs: _tabs,
        index: _index,
        onTap: _go,
      ),
    );
  }
}

class _KineticNavBar extends StatelessWidget {
  const _KineticNavBar({
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<({IconData icon, String label})> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StudioATheme.bg,
        border: Border(top: BorderSide(color: StudioATheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: tabs[i].icon,
                        label: tabs[i].label,
                        active: i == index,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: active ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            final color =
                Color.lerp(StudioATheme.inkDim, StudioATheme.volt, t)!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ukošeni volt indikator — „štafetna palica" aktivnog taba.
                Transform(
                  transform: Matrix4.skewX(-0.5),
                  alignment: Alignment.center,
                  child: Container(
                    width: 26 * t,
                    height: 3,
                    color: StudioATheme.volt.withValues(alpha: t),
                  ),
                ),
                const SizedBox(height: 7),
                Transform.translate(
                  offset: Offset(0, 2 * (1 - t)),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: StudioATheme.label(
                    size: 8.5,
                    tracking: 1.6,
                    color: color,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
