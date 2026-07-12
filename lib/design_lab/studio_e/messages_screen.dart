import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'chat_thread_screen.dart';
import 'shell.dart';
import 'theme.dart';
import 'widgets.dart';

/// Poruke — lista razgovora. Nepročitani nose glow tačku; tap gura thread.
class StudioEMessagesScreen extends StatefulWidget {
  const StudioEMessagesScreen({super.key, required this.session});

  final StudioESession session;

  @override
  State<StudioEMessagesScreen> createState() => _StudioEMessagesScreenState();
}

class _StudioEMessagesScreenState extends State<StudioEMessagesScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open(int index) async {
    setState(() => widget.session.readThreads.add(index));
    await Navigator.of(context).push(
      StudioEPageRoute<void>(
        builder: (_) => StudioEChatThreadScreen(
          threadIndex: index,
          session: widget.session,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  MockMessage _lastMessage(int index) {
    final extra = widget.session.extraMessages[index];
    if (extra != null && extra.isNotEmpty) return extra.last;
    return mockThreads[index].messages.last;
  }

  String _lastTime(int index) {
    final extra = widget.session.extraMessages[index];
    if (extra != null && extra.isNotEmpty) return extra.last.time;
    return mockThreads[index].lastTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          StudioEParallaxBackdrop(controller: _scroll),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    StudioESpace.xl,
                    StudioESpace.l,
                    StudioESpace.xl,
                    StudioESpace.section,
                  ),
                  children: [
                    StudioEEntrance(
                      child: StudioEGradientText(
                        'Poruke',
                        style: theme.displaySmall!,
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xs + 2),
                    StudioEEntrance(
                      delayMs: 60,
                      child: Text(
                        'Razgovori sa tvojim trenerima.',
                        style: theme.bodyMedium!
                            .copyWith(color: StudioEColors.textDim),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xl),
                    for (var i = 0; i < mockThreads.length; i++) ...[
                      StudioEEntrance(
                        delayMs: 110 + i * 70,
                        child: _ThreadTile(
                          name: mockThreads[i].trainerName,
                          preview: _preview(i),
                          time: _lastTime(i),
                          unread: !widget.session.readThreads.contains(i),
                          onTap: () => _open(i),
                        ),
                      ),
                      if (i < mockThreads.length - 1)
                        const SizedBox(height: StudioESpace.m),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _preview(int index) {
    final last = _lastMessage(index);
    final prefix = last.fromMe ? 'Ti: ' : '';
    return '$prefix${last.text}';
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final String name;
  final String preview;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return StudioEDepthCard(
      onTap: onTap,
      emphasis: unread,
      glowColor: StudioEColors.violet,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              StudioEAvatar(name: name, size: 50),
              if (unread)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StudioEColors.cyan,
                      border: Border.all(color: StudioEColors.layer1, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: StudioEColors.cyan.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: StudioESpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.titleMedium!.copyWith(
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: theme.bodySmall!.copyWith(
                        color: unread
                            ? StudioEColors.cyan
                            : StudioEColors.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall!.copyWith(
                    color: unread
                        ? StudioEColors.text
                        : StudioEColors.textDim,
                    fontWeight:
                        unread ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
