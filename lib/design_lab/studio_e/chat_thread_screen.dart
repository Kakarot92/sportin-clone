import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'shell.dart';
import 'theme.dart';
import 'widgets.dart';

/// Chat thread (push): moji bubble-ovi cyan tint, trenerovi violet tint.
/// Slanje poruke je mock (dodaje se u sesiju + trener „odgovori" jednom).
class StudioEChatThreadScreen extends StatefulWidget {
  const StudioEChatThreadScreen({
    super.key,
    required this.threadIndex,
    required this.session,
  });

  final int threadIndex;
  final StudioESession session;

  @override
  State<StudioEChatThreadScreen> createState() =>
      _StudioEChatThreadScreenState();
}

class _StudioEChatThreadScreenState extends State<StudioEChatThreadScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  MockThread get _thread => mockThreads[widget.threadIndex];

  List<MockMessage> get _messages => [
        ..._thread.messages,
        ...?widget.session.extraMessages[widget.threadIndex],
      ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutQuint,
    );
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final extra = widget.session.extraMessages
        .putIfAbsent(widget.threadIndex, () => <MockMessage>[]);
    setState(() {
      extra.add(MockMessage(text: text, fromMe: true, time: 'sada'));
      _input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    // Trener odgovori jednom po sesiji (mock živosti).
    if (!widget.session.autoReplied.contains(widget.threadIndex)) {
      widget.session.autoReplied.add(widget.threadIndex);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          extra.add(MockMessage(
            text: 'Primljeno! Vidimo se na treningu. 💪',
            fromMe: false,
            time: 'sada',
          ));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final messages = _messages;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const StudioEParallaxBackdrop(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    // Header sa avatarom trenera.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        StudioESpace.l,
                        StudioESpace.s,
                        StudioESpace.l,
                        StudioESpace.s,
                      ),
                      child: Row(
                        children: [
                          const StudioEBackButton(),
                          const SizedBox(width: StudioESpace.m),
                          StudioEAvatar(name: _thread.trainerName, size: 42),
                          const SizedBox(width: StudioESpace.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _thread.trainerName,
                                  style: theme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: StudioEColors.cyan,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text('na vezi', style: theme.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: StudioEColors.hairline,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(
                          StudioESpace.l,
                          StudioESpace.l,
                          StudioESpace.l,
                          StudioESpace.l,
                        ),
                        itemCount: messages.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return const _DayDivider(label: 'Razgovor');
                          }
                          final msg = messages[i - 1];
                          final prev = i - 2 >= 0 ? messages[i - 2] : null;
                          final grouped =
                              prev != null && prev.fromMe == msg.fromMe;
                          return Padding(
                            padding: EdgeInsets.only(
                              top: grouped ? 3 : StudioESpace.m,
                            ),
                            child: _Bubble(message: msg),
                          );
                        },
                      ),
                    ),
                    _Composer(
                      controller: _input,
                      focusNode: _inputFocus,
                      onSend: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: StudioESpace.s),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: StudioESpace.m, vertical: 4),
          decoration: BoxDecoration(
            color: StudioEColors.layer1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StudioEColors.hairline),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: StudioEColors.textDim,
            ),
          ),
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
    final me = message.fromMe;
    final tint = me
        ? StudioEColors.cyan.withValues(alpha: 0.14)
        : StudioEColors.violet.withValues(alpha: 0.13);
    final borderColor = me
        ? StudioEColors.cyan.withValues(alpha: 0.35)
        : StudioEColors.violet.withValues(alpha: 0.30);

    return Row(
      mainAxisAlignment:
          me ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: StudioESpace.l - 2,
              vertical: StudioESpace.m - 2,
            ),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(me ? 18 : 5),
                bottomRight: Radius.circular(me ? 5 : 18),
              ),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment:
                  me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14.5,
                    height: 1.4,
                    color: StudioEColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.time,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: StudioEColors.textDim,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        StudioESpace.l,
        StudioESpace.s,
        StudioESpace.l,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            StudioESpace.s,
      ),
      decoration: const BoxDecoration(
        color: StudioEColors.layer1,
        border: Border(top: BorderSide(color: StudioEColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: StudioEColors.layer2,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: StudioEColors.hairline),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: StudioESpace.l,
                    vertical: StudioESpace.m,
                  ),
                  hintText: 'Napiši poruku…',
                  hintStyle: GoogleFonts.ibmPlexSans(
                    fontSize: 14.5,
                    color: StudioEColors.textDim,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: StudioESpace.s),
          Semantics(
            button: true,
            label: 'Pošalji',
            child: GestureDetector(
              onTap: onSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [StudioEColors.cyan, Color(0xFF7BEFE0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: StudioEColors.cyan.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 22,
                  color: StudioEColors.onCyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
