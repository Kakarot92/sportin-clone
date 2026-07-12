import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'chat_thread_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// Poruke — lista korespondencije: svaki razgovor je hairline red sa
/// serif imenom, izvodom poslednje poruke i vremenom uz desnu marginu.
class StudioCMessagesTab extends StatelessWidget {
  const StudioCMessagesTab({super.key});

  void _openThread(BuildContext context, int index) {
    Navigator.of(context).push(
      StudioCRoute(builder: (_) => StudioCChatThreadScreen(index: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        StudioCTokens.margin,
        14,
        StudioCTokens.margin,
        28,
      ),
      children: [
        StudioCPageColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudioCReveal(
                order: 0,
                child: StudioCKicker(
                  index: '04',
                  label: 'Poruke',
                  trailing: '${mockThreads.length} RAZGOVORA',
                ),
              ),
              const SizedBox(height: 18),
              StudioCReveal(
                order: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Korespondencija', style: StudioCType.display(32)),
                    const SizedBox(height: 10),
                    Text(
                      'Prepiska sa trenerima — hronološki, bez žurbe.',
                      style: StudioCType.body(color: StudioCTokens.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const StudioCReveal(order: 2, child: StudioCDoubleRule()),
              for (var i = 0; i < mockThreads.length; i++)
                StudioCReveal(
                  order: 3 + i,
                  child: _ThreadRow(
                    index: i,
                    thread: mockThreads[i],
                    onTap: () => _openThread(context, i),
                  ),
                ),
              const StudioCHairline(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.index,
    required this.thread,
    required this.onTap,
  });

  final int index;
  final MockThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = thread.messages.last;
    final preview = last.fromMe ? 'Vi: ${last.text}' : last.text;
    final initials = _initials(thread.trainerName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (index > 0) const StudioCHairline(),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inicijali u hairline kvadratu — bez fotografije.
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: StudioCTokens.ink, width: 1),
                  ),
                  child: Text(
                    initials,
                    style: StudioCType.display(15, weight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              thread.trainerName,
                              style: StudioCType.display(
                                18,
                                weight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            thread.lastTime.toUpperCase(),
                            style: StudioCType.meta(size: 8.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preview,
                        style: StudioCType.body(
                          size: 13,
                          color: StudioCTokens.inkSoft,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${thread.messages.length} PORUKA U NIZU',
                        style: StudioCType.meta(size: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
