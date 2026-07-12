import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_tab.dart';
import 'measurements_tab.dart';
import 'messages_tab.dart';
import 'profile_tab.dart';
import 'schedule_tab.dart';
import 'theme.dart';
import 'widgets.dart';

/// Shell sa 5 tabova. Navigacija bez ikonica: serif redni brojevi
/// (01–05) + uppercase labele — sekcije magazina, ne toolbar.
class StudioCShell extends StatefulWidget {
  const StudioCShell({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  State<StudioCShell> createState() => _StudioCShellState();
}

class _StudioCShellState extends State<StudioCShell> {
  int _index = 0;

  static const _labels = ['Početna', 'Termini', 'Merenja', 'Poruke', 'Profil'];

  Widget _page(int i) {
    switch (i) {
      case 0:
        return StudioCHomeTab(
          key: const ValueKey('studio-c-home'),
          onOpenSection: (tab) => setState(() => _index = tab),
        );
      case 1:
        return const StudioCScheduleTab(key: ValueKey('studio-c-schedule'));
      case 2:
        return const StudioCMeasurementsTab(
          key: ValueKey('studio-c-measurements'),
        );
      case 3:
        return const StudioCMessagesTab(key: ValueKey('studio-c-messages'));
      default:
        return StudioCProfileTab(
          key: const ValueKey('studio-c-profile'),
          onExit: widget.onExit,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: StudioCTokens.beat,
            switchInCurve: StudioCTokens.ease,
            switchOutCurve: StudioCTokens.ease,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.006),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _page(_index),
          ),
        ),
        bottomNavigationBar: _EditorialNavBar(
          index: _index,
          labels: _labels,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

class _EditorialNavBar extends StatelessWidget {
  const _EditorialNavBar({
    required this.index,
    required this.labels,
    required this.onTap,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioCTokens.bone,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StudioCHairline(),
          SafeArea(
            top: false,
            child: StudioCPageColumn(
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: _NavItem(
                          numeral: StudioCFmt.two(i + 1),
                          label: labels[i],
                          active: i == index,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.numeral,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String numeral;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Semantics(
        selected: active,
        button: true,
        label: label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: StudioCTokens.beat,
              curve: StudioCTokens.ease,
              style: StudioCType.numeral(
                15,
                color: active
                    ? StudioCTokens.terracotta
                    : StudioCTokens.inkSoft.withValues(alpha: 0.85),
                weight: active ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(numeral),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: StudioCTokens.beat,
              curve: StudioCTokens.ease,
              style: StudioCType.kicker(
                size: 8.5,
                letterSpacing: 1.1,
                color: active ? StudioCTokens.ink : StudioCTokens.inkSoft,
                weight: active ? FontWeight.w700 : FontWeight.w500,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label.toUpperCase()),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: StudioCTokens.beat,
              curve: StudioCTokens.ease,
              height: 1.5,
              width: active ? 16 : 0,
              color: StudioCTokens.ink,
            ),
          ],
        ),
      ),
    );
  }
}
