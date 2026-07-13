import 'package:flutter/material.dart';
import 'package:sportin_clone/app/placeholder_scaffold.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScaffold(
      eyebrow: l10n.comingSoon,
      title: l10n.chatTitle,
      message: l10n.chatPlaceholder,
      icon: Icons.chat_bubble_outline,
      ghostLabel: '»',
    );
  }
}
