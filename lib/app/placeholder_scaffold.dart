import 'package:flutter/material.dart';

import 'kinetic.dart';
import 'kinetic_effects.dart';
import 'theme.dart';

/// Kinetik-styled titled screen with a SpeedLines backdrop, a GhostText
/// depth layer, and a staggered Reveal entrance.
/// Used by feature tabs whose real content arrives in later milestones.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.icon,
    this.ghostLabel,
  });

  final String eyebrow;
  final String title;
  final String message;
  final IconData icon;

  /// Optional ghost label. If null, derives from the first character of [title].
  final String? ghostLabel;

  String _ghost() {
    if (ghostLabel != null && ghostLabel!.isNotEmpty) return ghostLabel!;
    return title.isNotEmpty ? title[0].toUpperCase() : '·';
  }

  @override
  Widget build(BuildContext context) {
    final ghost = _ghost();

    return Scaffold(
      backgroundColor: kInk,
      body: Stack(
        children: [
          // Faint speed-lines texture backdrop.
          const Positioned.fill(
            child: SpeedLines(
              density: 22,
              seed: 77,
              opacity: 0.40,
              voltShare: 0.10,
            ),
          ),
          // Giant ghost label bleeding off the right edge for depth.
          Positioned(
            right: -24,
            bottom: 72,
            child: GhostText(
              ghost,
              size: 200,
              color: kLineDark,
              strokeWidth: 1.6,
            ),
          ),
          // Foreground content inside safe area.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Reveal(index: 0, child: Eyebrow(eyebrow)),
                  const SizedBox(height: 10),
                  Reveal(index: 1, child: DisplayTitle(title)),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Reveal(
                            index: 2,
                            child: Icon(icon, size: 52, color: kVolt),
                          ),
                          const SizedBox(height: 16),
                          Reveal(
                            index: 3,
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
