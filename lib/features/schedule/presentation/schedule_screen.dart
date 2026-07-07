import 'package:flutter/material.dart';
import 'package:sportin_clone/app/placeholder_scaffold.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScaffold(
      title: l10n.scheduleTitle,
      message: l10n.schedulePlaceholder,
      icon: Icons.calendar_month,
    );
  }
}
