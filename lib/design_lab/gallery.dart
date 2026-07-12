import 'package:flutter/material.dart';

import 'studio_a/studio_a.dart';
import 'studio_b/studio_b.dart';
import 'studio_c/studio_c.dart';
import 'studio_d/studio_d.dart';
import 'studio_e/studio_e.dart';

/// Design Lab — galerija 5 studija. Orkestrator-owned; builderi je NE diraju.
class DesignLabApp extends StatelessWidget {
  const DesignLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design Lab — Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6E56CF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101014),
      ),
      home: const GalleryScreen(),
    );
  }
}

class _StudioEntry {
  const _StudioEntry({
    required this.letter,
    required this.name,
    required this.tagline,
    required this.swatches,
    required this.builder,
  });

  final String letter;
  final String name;
  final String tagline;
  final List<Color> swatches;
  final Widget Function(VoidCallback onExit) builder;
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static final List<_StudioEntry> _entries = [
    _StudioEntry(
      letter: 'A',
      name: 'Kinetik',
      tagline: 'Atletska energija — oversized type, volt na crnom',
      swatches: const [Color(0xFF0B0B0C), Color(0xFFCCFF00), Color(0xFFF5F5F2)],
      builder: (onExit) => StudioAApp(onExit: onExit),
    ),
    _StudioEntry(
      letter: 'B',
      name: 'Aurora',
      tagline: 'Wellness glass — mesh gradijenti, blur, mir',
      swatches: const [Color(0xFFE9F1FF), Color(0xFF6F5FE6), Color(0xFF2FB593)],
      builder: (onExit) => StudioBApp(onExit: onExit),
    ),
    _StudioEntry(
      letter: 'C',
      name: 'Editorial Noir',
      tagline: 'Premium magazin — serif, bone papir, terakota',
      swatches: const [Color(0xFFF4EFE6), Color(0xFF17140F), Color(0xFFC4572E)],
      builder: (onExit) => StudioCApp(onExit: onExit),
    ),
    _StudioEntry(
      letter: 'D',
      name: 'Blok',
      tagline: 'Neo-brutalist data — tvrde ivice, mono brojevi, stikeri',
      swatches: const [Color(0xFFF2F0EB), Color(0xFFFFD02F), Color(0xFF2B5BFF)],
      builder: (onExit) => StudioDApp(onExit: onExit),
    ),
    _StudioEntry(
      letter: 'E',
      name: 'Dubina',
      tagline: 'Neon cinema — slojevi, glow, parallax dark',
      swatches: const [Color(0xFF0C0F14), Color(0xFF53E8D4), Color(0xFFB26BFF)],
      builder: (onExit) => StudioEApp(onExit: onExit),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Lab — izaberi dizajn')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final e = _entries[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(child: Text(e.letter)),
              title: Text(
                'Studio ${e.letter} — ${e.name}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    ...e.swatches.map(
                      (c) => Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        e.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        e.builder(() => Navigator.of(context).pop()),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
