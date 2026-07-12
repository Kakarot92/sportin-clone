import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock_data.dart';
import '../theme.dart';
import '../widgets/effects.dart';

/// Poruke — lista razgovora; tamno i čisto, bubble-ovi oštrih ivica.
class StudioAMessagesScreen extends StatelessWidget {
  const StudioAMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  StudioAReveal(
                    index: 0,
                    child: Text(
                      'RAZGOVORI SA TRENERIMA',
                      style: StudioATheme.label(
                        color: StudioATheme.volt,
                        size: 10.5,
                        tracking: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 1,
                    child:
                        Text('PORUKE', style: StudioATheme.display(size: 38)),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < mockThreads.length; i++)
                    StudioAReveal(
                      index: 2 + i,
                      child: _ThreadRow(thread: mockThreads[i]),
                    ),
                  const SizedBox(height: 24),
                  StudioAReveal(
                    index: 2 + mockThreads.length,
                    child: Center(
                      child: Text(
                        'Odgovaramo obično u roku od par sati.',
                        style: StudioATheme.body(
                          size: 12,
                          color: StudioATheme.inkDim,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.thread});

  final MockThread thread;

  bool get _isFresh {
    // „Sveže": poslednja poruka danas (vreme HH:mm) i nije moja.
    final last = thread.messages.last;
    return thread.lastTime.contains(':') && !last.fromMe;
  }

  @override
  Widget build(BuildContext context) {
    final last = thread.messages.last;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          studioARoute(StudioAChatThreadScreen(thread: thread)),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StudioATheme.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StudioAInitials(thread.trainerName, voltBorder: _isFresh),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.trainerName.toUpperCase(),
                    style: GoogleFonts.archivoBlack(
                      fontSize: 13.5,
                      color: StudioATheme.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    last.text,
                    style: StudioATheme.body(
                      size: 13,
                      color: StudioATheme.inkDim,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.lastTime.toUpperCase(),
                  style: StudioATheme.label(
                    size: 9.5,
                    tracking: 1.2,
                    color: _isFresh ? StudioATheme.volt : StudioATheme.inkDim,
                  ),
                ),
                const SizedBox(height: 6),
                if (_isFresh)
                  Transform(
                    transform: Matrix4.skewX(-0.35),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: StudioATheme.volt,
                      child: Text(
                        'NOVO',
                        style: GoogleFonts.archivoBlack(
                          fontSize: 7.5,
                          color: StudioATheme.bg,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Chat thread — bubble-ovi oštrih ivica, moji sa volt levom ivicom.
// ═══════════════════════════════════════════════════════════════════════

class StudioAChatThreadScreen extends StatefulWidget {
  const StudioAChatThreadScreen({super.key, required this.thread});

  final MockThread thread;

  @override
  State<StudioAChatThreadScreen> createState() =>
      _StudioAChatThreadScreenState();
}

class _StudioAChatThreadScreenState extends State<StudioAChatThreadScreen> {
  late final List<MockMessage> _messages;
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  bool _canSend = false;

  MockTrainer? get _trainer {
    for (final t in mockTrainers) {
      if (t.name == widget.thread.trainerName) return t;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.thread.messages);
    _composer.addListener(() {
      final can = _composer.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    final now = TimeOfDay.now();
    final stamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _messages.add(MockMessage(text: text, fromMe: true, time: stamp));
      _composer.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            '— POČETAK RAZGOVORA —',
                            style: StudioATheme.label(
                              size: 8.5,
                              tracking: 2.4,
                              color: StudioATheme.inkDim,
                            ),
                          ),
                        ),
                      ),
                      for (var i = 0; i < _messages.length; i++)
                        StudioAReveal(
                          index: i < widget.thread.messages.length ? i : 0,
                          child: _Bubble(message: _messages[i]),
                        ),
                    ],
                  ),
                ),
                _composerBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final trainer = _trainer;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: StudioATheme.line)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: StudioAReveal(
        index: 0,
        dy: -10,
        child: Row(
          children: [
            StudioAIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Nazad',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 14),
            StudioAInitials(widget.thread.trainerName, size: 42, fontSize: 13),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.thread.trainerName.toUpperCase(),
                    style: GoogleFonts.archivoBlack(
                      fontSize: 13.5,
                      color: StudioATheme.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trainer != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      trainer.specialty.toUpperCase(),
                      style: StudioATheme.label(
                        size: 8.5,
                        color: StudioATheme.volt,
                        tracking: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composerBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StudioATheme.line)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _composer,
              style: StudioATheme.body(size: 14.5),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Napiši poruku…',
                hintStyle: StudioATheme.body(
                  size: 14.5,
                  color: StudioATheme.inkDim.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: StudioATheme.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: StudioATheme.line),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: StudioATheme.volt, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Pošalji poruku',
            child: AnimatedOpacity(
              opacity: _canSend ? 1 : 0.45,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Material(
                color: StudioATheme.volt,
                child: InkWell(
                  onTap: _send,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 22,
                      color: StudioATheme.bg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: mine ? Colors.transparent : StudioATheme.surface,
                border: mine
                    ? const Border(
                        left: BorderSide(color: StudioATheme.volt, width: 3),
                        top: BorderSide(color: StudioATheme.line),
                        right: BorderSide(color: StudioATheme.line),
                        bottom: BorderSide(color: StudioATheme.line),
                      )
                    : null,
              ),
              child: Text(
                message.text,
                style: StudioATheme.body(size: 14, height: 1.45),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time.toUpperCase(),
              style: StudioATheme.label(
                size: 8.5,
                tracking: 1.4,
                color: StudioATheme.inkDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
