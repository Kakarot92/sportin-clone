import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/date_utils.dart';
import 'package:sportin_clone/features/scheduling/domain/studio_settings.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Admin screen to configure studio-wide closed weekdays and specific dates.
///
/// Route: /profile/studio
/// Guard: admin-only
class StudioClosedDaysScreen extends ConsumerStatefulWidget {
  const StudioClosedDaysScreen({super.key});

  @override
  ConsumerState<StudioClosedDaysScreen> createState() =>
      _StudioClosedDaysScreenState();
}

class _StudioClosedDaysScreenState
    extends ConsumerState<StudioClosedDaysScreen> {
  StudioSettings? _local;
  bool _loaded = false;
  bool _saving = false;

  String _weekdayLabel(AppLocalizations l10n, int day) {
    switch (day) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
      default:
        return '$day';
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(availabilityRepositoryProvider)
          .saveStudioSettings(_local!);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addClosedDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;
    setState(() {
      final updated = Set<String>.from(_local!.closedDates)..add(ymd(date));
      _local = StudioSettings(
        closedWeekdays: _local!.closedWeekdays,
        closedDates: updated,
      );
    });
  }

  void _removeClosedDate(String dateStr) {
    setState(() {
      final updated = Set<String>.from(_local!.closedDates)..remove(dateStr);
      _local = StudioSettings(
        closedWeekdays: _local!.closedWeekdays,
        closedDates: updated,
      );
    });
  }

  void _toggleWeekday(int day, bool selected) {
    setState(() {
      final updated = Set<int>.from(_local!.closedWeekdays);
      if (selected) {
        updated.add(day);
      } else {
        updated.remove(day);
      }
      _local = StudioSettings(
        closedWeekdays: updated,
        closedDates: _local!.closedDates,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(appUserProvider).asData?.value;

    // Guard: admin-only.
    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final settingsAsync = ref.watch(studioSettingsProvider);
    if (!_loaded && settingsAsync.asData != null) {
      _local = settingsAsync.asData!.value;
      _loaded = true;
    }
    if (_local == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sortedDates = _local!.closedDates.toList()..sort();

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Admin'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.studioClosedDays),
          const SizedBox(height: 28),

          // ── Closed weekdays — volt skewed chips ──
          SectionHeader(l10n.closedWeekdaysLabel),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _local!.closedWeekdays.contains(day);
              return GestureDetector(
                onTap: () => _toggleWeekday(day, !selected),
                child: Transform(
                  transform: Matrix4.skewX(-0.10),
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? kVolt : Colors.transparent,
                      border: Border.all(
                        color: selected ? kVolt : kLineDark,
                        width: 1.5,
                      ),
                    ),
                    child: Transform(
                      transform: Matrix4.skewX(0.10),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.check,
                                  size: 14,
                                  color: selected ? kInk : kOffWhite),
                            ),
                          Text(
                            _weekdayLabel(l10n, day).toUpperCase(),
                            style: GoogleFonts.interTight(
                              color: selected ? kInk : kOffWhite,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // ── Closed specific dates ──
          SectionHeader(l10n.closedDatesLabel),
          const SizedBox(height: 12),
          if (sortedDates.isEmpty)
            Text('—', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...sortedDates.map((d) => _DateRow(
                  dateStr: d,
                  onDelete: () => _removeClosedDate(d),
                )),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _addClosedDate,
            icon: const Icon(Icons.add, size: 18, color: kVolt),
            label: Text(
              l10n.addClosedDate,
              style: GoogleFonts.interTight(
                color: kVolt,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 24),
          VoltButton(
            label: l10n.save,
            icon: Icons.check,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.dateStr, required this.onDelete});

  final String dateStr;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(dateStr, style: theme.textTheme.bodyLarge),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kDanger, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}
