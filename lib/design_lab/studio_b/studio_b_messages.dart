import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_b_aurora.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Poruke — lista razgovora. Tap otvara thread (push) sa Hero avatarom
/// trenera i glass bubble-ovima nad aurorom.
class StudioBMessagesTab extends StatelessWidget {
  const StudioBMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            StudioBReveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poruke',
                    style: StudioBTokens.display(
                      size: 27,
                      weight: FontWeight.w700,
                      spacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Razgovori sa tvojim trenerima',
                    style: StudioBTokens.body(
                      size: 13.5,
                      weight: FontWeight.w600,
                      color: StudioBTokens.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < mockThreads.length; i++) ...[
              StudioBReveal(
                delayMs: 100 + i * 90,
                child: _ThreadTile(
                  thread: mockThreads[i],
                  unread: i == 0,
                ),
              ),
              if (i < mockThreads.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.unread});

  final MockThread thread;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final last = thread.messages.last;
    final preview = '${last.fromMe ? 'Ti: ' : ''}${last.text}';

    return StudioBGlass(
      onTap: () => Navigator.of(context).push(
        studioBRoute<void>(StudioBThreadScreen(thread: thread)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        children: [
          StudioBAvatar(
            name: thread.trainerName,
            size: 54,
            heroTag: 'sb-thread-${thread.trainerName}',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        thread.trainerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StudioBTokens.display(
                          size: 15.5,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      thread.lastTime,
                      style: StudioBTokens.label(size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StudioBTokens.body(
                          size: 13,
                          weight: unread ? FontWeight.w700 : FontWeight.w500,
                          color: unread
                              ? StudioBTokens.ink
                              : StudioBTokens.inkSoft,
                        ),
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: StudioBTokens.violet,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thread — poruke kao glass bubble-ovi. Moje: violet tinta, uz desnu ivicu;
/// trenerove: bela glass, uz levu, sa malim avatarom. Kompozer je mock.
class StudioBThreadScreen extends StatefulWidget {
  const StudioBThreadScreen({super.key, required this.thread});

  final MockThread thread;

  @override
  State<StudioBThreadScreen> createState() => _StudioBThreadScreenState();
}

class _StudioBThreadScreenState extends State<StudioBThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) {
      return;
    }
    _focus.unfocus();
    _controller.clear();
    studioBShowSnack(
      context,
      'Poruka poslata (demo).',
      icon: Icons.send_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topSafe = MediaQuery.paddingOf(context).top;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final msgs = widget.thread.messages;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: StudioBAuroraBackground(
        veil: 0.06,
        child: Column(
          children: [
            // Zaglavlje sa Hero avatarom.
            Padding(
              padding: EdgeInsets.fromLTRB(12, topSafe + 10, 16, 8),
              child: Row(
                children: [
                  const _GlassIconButton(icon: Icons.arrow_back_rounded),
                  const SizedBox(width: 6),
                  StudioBAvatar(
                    name: widget.thread.trainerName,
                    size: 44,
                    heroTag: 'sb-thread-${widget.thread.trainerName}',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.thread.trainerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StudioBTokens.display(
                            size: 17,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: StudioBTokens.mint,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'trener · aktivan danas',
                              style: StudioBTokens.label(size: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: msgs.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return const _DayDivider(label: 'Danas');
                  }
                  final m = msgs[i - 1];
                  return StudioBReveal(
                    delayMs: 60 + (i - 1) * 70,
                    dy: 10,
                    child: _Bubble(message: m),
                  );
                },
              ),
            ),
            // Kompozer (mock).
            Padding(
              padding: EdgeInsets.fromLTRB(14, 4, 14, bottomSafe + 12),
              child: StudioBGlass(
                radius: 30,
                opacity: 0.72,
                blur: 22,
                padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 4,
                        style: StudioBTokens.body(size: 14.5),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Napiši poruku…',
                          hintStyle: StudioBTokens.body(
                            size: 14.5,
                            color: StudioBTokens.inkSoft,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SendButton(onTap: _send),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final MockMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(mine ? 20 : 6),
      bottomRight: Radius.circular(mine ? 6 : 20),
    );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 9),
      decoration: BoxDecoration(
        color: mine
            ? StudioBTokens.violet.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: radius,
        border: mine
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: StudioBTokens.violet.withValues(alpha: mine ? 0.24 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: StudioBTokens.body(
              size: 14.5,
              height: 1.4,
              weight: FontWeight.w500,
              color: mine ? Colors.white : StudioBTokens.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message.time,
            style: StudioBTokens.label(
              size: 10,
              color: mine
                  ? Colors.white.withValues(alpha: 0.85)
                  : StudioBTokens.inkSoft,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            const SizedBox(width: 2),
            bubble,
          ] else
            bubble,
        ],
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: StudioBTokens.label(size: 11, spacing: 0.4),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Pošalji poruku',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: StudioBTokens.ctaGradient,
            ),
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            size: 21,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      radius: 22,
      opacity: 0.6,
      blur: 16,
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).maybePop(),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icon, size: 22, color: StudioBTokens.ink),
      ),
    );
  }
}
