import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/chat/application/chat_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import 'chat_thread_widgets.dart';

/// Group class chat thread screen.
///
/// Route: /chat/group/:classId
///
/// Displays chronological messages for a group class chat with the same
/// bubble/input UI as the 1-on-1 screen. AS-069, AS-071.
class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
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

    final ok = await ref.read(chatControllerProvider.notifier).sendGroup(
          classId: widget.classId,
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
    final messagesAsync = ref.watch(groupMessagesProvider(widget.classId));

    return Scaffold(
      // REQUIRED: back button (AppBar must never be omitted on pushed screens).
      appBar: AppBar(
        title: Eyebrow(l10n.groupClassChat),
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
                      // reversed.toList() + reverse: true → newest at bottom.
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
