import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/chat/application/chat_providers.dart';
import 'package:sportin_clone/features/chat/data/chat_repository.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import 'chat_thread_widgets.dart';

/// 1-on-1 chat thread between a trainer and a client.
///
/// Route: /chat/thread/:trainerUid/:clientUid
///
/// Displays chronological messages with a bottom compose bar.
/// Messages from the current user appear right-aligned (kVolt bubble),
/// others appear left-aligned (kInkElevated bubble). AS-066, AS-067, AS-069.
class OneOnOneChatScreen extends ConsumerStatefulWidget {
  const OneOnOneChatScreen({
    super.key,
    required this.trainerUid,
    required this.clientUid,
  });

  final String trainerUid;
  final String clientUid;

  @override
  ConsumerState<OneOnOneChatScreen> createState() =>
      _OneOnOneChatScreenState();
}

class _OneOnOneChatScreenState extends ConsumerState<OneOnOneChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final can = _ctrl.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final me = ref.read(appUserProvider).asData?.value;
    if (me == null) return;

    final ok = await ref.read(chatControllerProvider.notifier).send(
          trainerUid: widget.trainerUid,
          clientUid: widget.clientUid,
          senderUid: me.uid,
          text: text,
        );

    if (ok) {
      _ctrl.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorGeneric),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Always use the trainer's display name as title (simplest and consistent).
    final trainerName = ref
        .watch(trainerProvider(widget.trainerUid))
        .asData
        ?.value
        ?.displayName;

    final threadId = ChatRepository.oneOnOneThreadId(
      widget.trainerUid,
      widget.clientUid,
    );
    final messagesAsync = ref.watch(oneOnOneMessagesProvider(threadId));

    return Scaffold(
      // REQUIRED: back button (AppBar must never be omitted on pushed screens).
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(l10n.chatMessages),
            if (trainerName != null && trainerName.isNotEmpty)
              Text(
                trainerName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
      ),
      body: me == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: messagesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) =>
                        Center(child: Text(l10n.errorGeneric)),
                    data: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noMessagesYet,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      // reversed.toList() + reverse: true → newest message
                      // sits at the bottom of the list (standard chat UX).
                      final reversed = messages.reversed.toList();
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: reversed.length,
                        itemBuilder: (_, i) => ChatMessageBubble(
                          message: reversed[i],
                          isMe: reversed[i].senderUid == me.uid,
                        ),
                      );
                    },
                  ),
                ),
                ChatInputBar(
                  controller: _ctrl,
                  canSend: _canSend,
                  onSend: _send,
                  hint: l10n.typeMessage,
                ),
              ],
            ),
    );
  }
}
