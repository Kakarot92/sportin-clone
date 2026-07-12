import 'package:flutter/material.dart';

import 'studio_b_aurora.dart';
import 'studio_b_glass.dart';
import 'studio_b_home.dart';
import 'studio_b_measurements.dart';
import 'studio_b_messages.dart';
import 'studio_b_profile.dart';
import 'studio_b_schedule.dart';
import 'studio_b_tokens.dart';

/// Školjka aplikacije: jedna aurora pozadina ispod svih tabova, plutajuća
/// glass navigacija i meki fade+lift prelaz između tabova. Signature potez:
/// svaki tab tiho pomera fazu aurore, pa se „nebo" prekomponuje dok korisnik
/// šeta kroz aplikaciju.
class StudioBShell extends StatefulWidget {
  const StudioBShell({super.key, required this.onLogout, this.onExit});

  final VoidCallback onLogout;
  final VoidCallback? onExit;

  @override
  State<StudioBShell> createState() => _StudioBShellState();
}

class _StudioBShellState extends State<StudioBShell> {
  int _index = 0;

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.home_rounded, label: 'Početna'),
    (icon: Icons.calendar_month_rounded, label: 'Termini'),
    (icon: Icons.monitor_weight_rounded, label: 'Merenja'),
    (icon: Icons.chat_bubble_rounded, label: 'Poruke'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  Widget _tab(int i) {
    switch (i) {
      case 0:
        return StudioBHomeTab(
          onQuickNav: (tab) => setState(() => _index = tab),
        );
      case 1:
        return const StudioBScheduleTab();
      case 2:
        return const StudioBMeasurementsTab();
      case 3:
        return const StudioBMessagesTab();
      default:
        return StudioBProfileTab(
          onLogout: widget.onLogout,
          onExit: widget.onExit,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _index * 0.08),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        builder: (_, drift, child) => StudioBAuroraBackground(
          drift: drift,
          veil: 0.06,
          child: child!,
        ),
        child: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.012),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(_index),
              child: _tab(_index),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: StudioBGlass(
              radius: 30,
              opacity: 0.72,
              blur: 24,
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: _items[i].icon,
                        label: _items[i].label,
                        active: i == _index,
                        onTap: () => setState(() => _index = i),
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
    final color = active ? StudioBTokens.violetDeep : StudioBTokens.inkSoft;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: 56,
          decoration: BoxDecoration(
            color: active
                ? StudioBTokens.violet.withValues(alpha: 0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 23, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: StudioBTokens.label(size: 10.5, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
