import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../domain/chat_message.dart';

/// A single message bubble used in both 1-on-1 and group chat threads.
///
/// [isMe] controls alignment and colour:
///   - true  → right-aligned, kVolt background, dark text (AS-066, AS-067)
///   - false → left-aligned, kInkElevated background, light text
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? kVolt : kInkElevated,
          border: isMe ? null : Border.all(color: kLineDark),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.interTight(
                fontSize: 14,
                color: isMe ? kInk : kOffWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.Hm().format(message.sentAt),
              style: GoogleFonts.interTight(
                fontSize: 10,
                color: isMe ? kInk.withValues(alpha: 0.55) : kMutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom input bar shared by 1-on-1 and group chat thread screens.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.hint,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border(top: BorderSide(color: kLineDark)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
            ),
            IconButton(
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send_rounded),
              color: kVolt,
              disabledColor: kMutedDark,
              tooltip: hint,
            ),
          ],
        ),
      ),
    );
  }
}
