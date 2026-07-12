import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'home_screen.dart';
import 'measurements_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'theme.dart';

/// Sesijsko stanje mock aplikacije — živi dok je korisnik ulogovan.
class StudioESession {
  /// Indeksi pročitanih razgovora (razgovor sa Anom je od juče — pročitan).
  final Set<int> readThreads = {1};

  /// Poruke poslate u ovoj sesiji, po indeksu razgovora.
  final Map<int, List<MockMessage>> extraMessages = {};

  /// Razgovori u kojima je trener već „odgovorio" u ovoj sesiji.
  final Set<int> autoReplied = {};
}

/// Shell sa 5 tabova; tranzicija tabova je fade-through + blaga skala,
/// aktivni tab nosi glow indikator.
class StudioEShell extends StatefulWidget {
  const StudioEShell({super.key, required this.onLogout, this.onExit});

  final VoidCallback onLogout;
  final VoidCallback? onExit;

  @override
  State<StudioEShell> createState() => _StudioEShellState();
}

class _StudioEShellState extends State<StudioEShell> {
  int _tab = 0;
  final StudioESession _session = StudioESession();

  void _goTo(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      StudioEHomeScreen(onGoToTab: _goTo),
      const StudioEScheduleScreen(),
      const StudioEMeasurementsScreen(),
      StudioEMessagesScreen(session: _session),
      StudioEProfileScreen(onLogout: widget.onLogout, onExit: widget.onExit),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutQuint,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(_tab),
          child: screens[_tab],
        ),
      ),
      bottomNavigationBar: _StudioENavBar(
        index: _tab,
        onSelect: _goTo,
        showChatDot: !_session.readThreads.contains(0),
      ),
    );
  }
}

class _StudioENavBar extends StatelessWidget {
  const _StudioENavBar({
    required this.index,
    required this.onSelect,
    required this.showChatDot,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final bool showChatDot;

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Početna'),
    (Icons.event_rounded, 'Termini'),
    (Icons.insights_rounded, 'Merenja'),
    (Icons.chat_bubble_rounded, 'Poruke'),
    (Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StudioEColors.layer1,
        border: Border(top: BorderSide(color: StudioEColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: _items[i].$1,
                        label: _items[i].$2,
                        active: i == index,
                        showDot: i == 3 && showChatDot,
                        onTap: () => onSelect(i),
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
    required this.showDot,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glow indikator aktivnog taba.
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutQuint,
              margin: const EdgeInsets.only(bottom: 5),
              height: 3,
              width: active ? 18 : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: StudioEColors.neon,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: StudioEColors.cyan.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Icon(
                    icon,
                    key: ValueKey<bool>(active),
                    size: 24,
                    color:
                        active ? StudioEColors.cyan : StudioEColors.textDim,
                  ),
                ),
                if (showDot)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: StudioEColors.cyan,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? StudioEColors.text : StudioEColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
