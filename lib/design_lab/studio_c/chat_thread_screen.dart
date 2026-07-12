import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Chat thread — „korespondencija": bez bubble-ova. Poruke trenera su
/// levo-poravnati pasusi, korisnikove desno-poravnate; svaka replika je
/// odvojena hairline separatorom sa uppercase pripisom (ko/kada).
class StudioCChatThreadScreen extends StatefulWidget {
  const StudioCChatThreadScreen({super.key, required this.index});

  final int index;

  @override
  State<StudioCChatThreadScreen> createState() =>
      _StudioCChatThreadScreenState();
}

class _StudioCChatThreadScreenState extends State<StudioCChatThreadScreen> {
  final _composer = TextEditingController();

  MockThread get _thread => mockThreads[widget.index];

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    FocusScope.of(context).unfocus();
    StudioCNote.show(context, 'Poruka je zabeležena u prepisci.');
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;
    final me = mockUser.name;

    return Scaffold(
      body: SafeArea(
        child: StudioCPageColumn(
          child: Column(
            children: [
              // Zaglavlje.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  StudioCTokens.margin,
                  8,
                  StudioCTokens.margin,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '←  PORUKE',
                              style: StudioCType.kicker(
                                size: 10,
                                color: StudioCTokens.ink,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${thread.messages.length} REPLIKA',
                          style: StudioCType.meta(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      thread.trainerName,
                      style: StudioCType.display(26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PREPISKA · POSLEDNJA ${thread.lastTime.toUpperCase()}',
                      style: StudioCType.meta(size: 9),
                    ),
                    const SizedBox(height: 12),
                    const StudioCDoubleRule(),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    StudioCTokens.margin,
                    18,
                    StudioCTokens.margin,
                    24,
                  ),
                  itemCount: thread.messages.length + 1,
                  itemBuilder: (context, i) {
                    if (i == thread.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Column(
                          children: [
                            const StudioCHairline(),
                            const SizedBox(height: 10),
                            Text(
                              '— KRAJ PREPISKE —',
                              style: StudioCType.meta(
                                size: 8.5,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final msg = thread.messages[i];
                    return StudioCReveal(
                      order: i,
                      dy: 10,
                      child: _Entry(
                        msg: msg,
                        author: msg.fromMe ? me : thread.trainerName,
                        showRule: i > 0,
                      ),
                    );
                  },
                ),
              ),
              // Composer.
              _Composer(controller: _composer, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.msg,
    required this.author,
    required this.showRule,
  });

  final MockMessage msg;
  final String author;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    final align =
        msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = msg.fromMe ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showRule)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                if (msg.fromMe) const Spacer(),
                SizedBox(
                  width: 44,
                  child: StudioCHairline(
                    color: msg.fromMe
                        ? StudioCTokens.terracotta.withValues(alpha: 0.6)
                        : StudioCTokens.hairline,
                  ),
                ),
                if (!msg.fromMe) const Spacer(),
              ],
            ),
          ),
        Column(
          crossAxisAlignment: align,
          children: [
            // Pripis: ko + kada.
            Text(
              '${author.toUpperCase()} · ${msg.time.toUpperCase()}',
              style: StudioCType.meta(
                size: 8.5,
                color: msg.fromMe
                    ? StudioCTokens.terracotta
                    : StudioCTokens.inkSoft,
                letterSpacing: 1.4,
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                msg.text,
                style: StudioCType.body(
                  size: 15,
                  height: 1.5,
                  style: msg.fromMe ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StudioCTokens.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(StudioCTokens.margin, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              cursorWidth: 1.4,
              cursorColor: StudioCTokens.ink,
              style: StudioCType.body(size: 15),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Napišite poruku…',
                hintStyle: StudioCType.body(
                  size: 15,
                  color: StudioCTokens.inkSoft.withValues(alpha: 0.7),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSend,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              child: Text(
                'POŠALJI',
                style: StudioCType.kicker(
                  size: 11,
                  color: StudioCTokens.terracotta,
                  letterSpacing: 2,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
