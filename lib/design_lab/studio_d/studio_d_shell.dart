import 'package:flutter/material.dart';

import 'studio_d_home.dart';
import 'studio_d_measurements.dart';
import 'studio_d_messages.dart';
import 'studio_d_profile.dart';
import 'studio_d_theme.dart';
import 'studio_d_trainers.dart';

/// Shell studija: 5 tabova + blok-navigacija na dnu (aktivan tab = žuti blok).
class StudioDShell extends StatefulWidget {
  const StudioDShell({super.key, this.onExit, required this.onLogout});

  final VoidCallback? onExit;
  final VoidCallback onLogout;

  @override
  State<StudioDShell> createState() => _StudioDShellState();
}

class _StudioDShellState extends State<StudioDShell> {
  int _tab = 0;

  static const _labels = ['Početna', 'Termini', 'Merenja', 'Poruke', 'Profil'];
  static const _icons = [
    Icons.dashboard_sharp,
    Icons.calendar_month_sharp,
    Icons.bar_chart_sharp,
    Icons.chat_bubble_sharp,
    Icons.person_sharp,
  ];

  void _select(int i) {
    if (i != _tab) setState(() => _tab = i);
  }

  Widget _screenFor(int i) {
    switch (i) {
      case 0:
        return StudioDHomeScreen(onGoToTab: _select);
      case 1:
        return const StudioDTrainersScreen();
      case 2:
        return const StudioDMeasurementsScreen();
      case 3:
        return const StudioDMessagesScreen();
      default:
        return StudioDProfileScreen(
          onExit: widget.onExit,
          onLogout: widget.onLogout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_tab),
                child: _screenFor(_tab),
              ),
            ),
          ),
          _StudioDNavBar(
            labels: _labels,
            icons: _icons,
            current: _tab,
            onSelect: _select,
          ),
        ],
      ),
    );
  }
}

class _StudioDNavBar extends StatelessWidget {
  const _StudioDNavBar({
    required this.labels,
    required this.icons,
    required this.current,
    required this.onSelect,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StudioDColors.white,
        border: Border(top: BorderSide(color: StudioDColors.ink, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: _StudioDNavItem(
                      label: labels[i],
                      icon: icons[i],
                      active: i == current,
                      onTap: () => onSelect(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudioDNavItem extends StatelessWidget {
  const _StudioDNavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: active ? 10 : 6,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: active ? StudioDColors.yellow : StudioDColors.white,
                border: Border.all(
                  color: active ? StudioDColors.ink : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: StudioDColors.ink),
                  const SizedBox(height: 3),
                  Text(
                    label.toUpperCase(),
                    style: StudioDType.mono(
                      size: 8,
                      weight: FontWeight.w700,
                      spacing: 0.3,
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
