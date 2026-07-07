import 'package:flutter/material.dart';
import 'package:sportin_clone/app/placeholder_scaffold.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScaffold(
      title: l10n.measurementsTitle,
      message: l10n.measurementsPlaceholder,
      icon: Icons.straighten,
    );
  }
}
