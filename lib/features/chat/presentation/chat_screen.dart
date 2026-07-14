import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/trainer_profile.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/chat/application/chat_providers.dart';
import 'package:sportin_clone/features/chat/domain/chat_thread_summary.dart';
import 'package:sportin_clone/features/group_classes/application/group_class_providers.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Chat tab landing screen — lists 1-on-1 threads and group-class chats.
///
/// Tab landing screens MUST NOT have an AppBar (matches other tab screens like
/// TrainerDirectoryScreen, ProfileScreen). The AppBar lives on pushed routes.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Show loading until the current user profile resolves.
    if (me == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Faint speed-lines backdrop — matches other tab landing screens.
          const Positioned.fill(
            child: SpeedLines(density: 14, seed: 9, opacity: 0.18),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page header ──────────────────────────────────────
                      Reveal(index: 0, child: Eyebrow(l10n.navChat)),
                      const SizedBox(height: 6),
                      Reveal(
                        index: 1,
                        child: DisplayTitle(l10n.chatMessages, size: 38),
                      ),
                      const SizedBox(height: 24),

                      // ── Trainer: existing conversation threads ────────────
                      if (me.isTrainer) ...[
                        Reveal(
                          index: 2,
                          child: SectionHeader(l10n.myChats),
                        ),
                        const SizedBox(height: 12),
                        _TrainerThreadsList(trainerUid: me.uid),
                        const SizedBox(height: 24),
                      ],

                      // ── Chat with trainer — shown to everyone ─────────────
                      Reveal(
                        index: 3,
                        child: SectionHeader(l10n.chatWithTrainer),
                      ),
                      const SizedBox(height: 12),
                      _AllTrainersList(clientUid: me.uid),
                      const SizedBox(height: 24),

                      // ── Group class chats ─────────────────────────────────
                      Reveal(
                        index: 4,
                        child: SectionHeader(l10n.groupClassChat),
                      ),
                      const SizedBox(height: 12),
                      if (me.isTrainer)
                        _TrainerGroupChatList(trainerUid: me.uid)
                      else
                        _ClientGroupChatList(clientUid: me.uid),
                    ],
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

// ── Trainer: existing 1-on-1 thread list ──────────────────────────────────────

class _TrainerThreadsList extends ConsumerWidget {
  const _TrainerThreadsList({required this.trainerUid});

  final String trainerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final threadsAsync = ref.watch(trainerChatThreadsProvider(trainerUid));

    return threadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.errorGeneric),
      data: (threads) {
        if (threads.isEmpty) {
          return Text(
            l10n.noChatsYet,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          children: [
            for (var i = 0; i < threads.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Reveal(
                index: 5 + i,
                child: _ThreadCard(thread: threads[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Card showing a 1-on-1 conversation thread summary.
/// Tapping navigates to the thread screen for the trainer/client pair.
class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final ChatThreadSummary thread;

  @override
  Widget build(BuildContext context) {
    // Use first char of client uid as initials placeholder since we don't have
    // a generic userProvider to fetch the client's display name.
    final initials =
        thread.clientUid.isEmpty ? '?' : thread.clientUid.substring(0, 1);

    String dateStr = '';
    if (thread.lastMessageAt != null) {
      try {
        dateStr =
            DateFormat.yMMMEd('sr_Latn').format(thread.lastMessageAt!);
      } catch (_) {}
    }

    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: () => context.push(
          '/chat/thread/${thread.trainerUid}/${thread.clientUid}',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              KineticInitials(initials, size: 48, fontSize: 15),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.lastMessage.isNotEmpty
                          ? thread.lastMessage
                          : '…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.interTight(
                        fontSize: 14,
                        color: kOffWhite,
                      ),
                    ),
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.interTight(
                          fontSize: 12,
                          color: kMutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: kVolt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── All trainers list — available to everyone to start a 1-on-1 chat ──────────

class _AllTrainersList extends ConsumerWidget {
  const _AllTrainersList({required this.clientUid});

  final String clientUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trainersAsync = ref.watch(trainersListProvider);

    return trainersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.errorGeneric),
      data: (trainers) {
        if (trainers.isEmpty) {
          return Text(
            l10n.noTrainers,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          children: [
            for (var i = 0; i < trainers.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Reveal(
                index: 10 + i,
                child: _TrainerChatCard(
                  trainer: trainers[i],
                  clientUid: clientUid,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Trainer card that navigates to the 1-on-1 chat thread on tap.
/// Visual grammar mirrors _TrainerCard in trainer_directory_screen.dart.
class _TrainerChatCard extends StatelessWidget {
  const _TrainerChatCard({
    required this.trainer,
    required this.clientUid,
  });

  final TrainerProfile trainer;
  final String clientUid;

  @override
  Widget build(BuildContext context) {
    final name =
        trainer.displayName.isEmpty ? '?' : trainer.displayName;
    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: () =>
            context.push('/chat/thread/${trainer.uid}/$clientUid'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              KineticInitials(name, size: 48, fontSize: 15),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: GoogleFonts.archivoBlack(
                        fontSize: 16,
                        color: kOffWhite,
                        height: 1.05,
                      ),
                    ),
                    if (trainer.bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        trainer.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 13,
                          color: kMutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: kVolt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Group class chat sections ─────────────────────────────────────────────────

/// Group class chat list for a trainer — shows all classes they created.
class _TrainerGroupChatList extends ConsumerWidget {
  const _TrainerGroupChatList({required this.trainerUid});

  final String trainerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final classesAsync = ref.watch(trainerGroupClassesProvider(trainerUid));

    return classesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.errorGeneric),
      data: (classes) {
        if (classes.isEmpty) {
          return Text(
            l10n.noChatsYet,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          children: [
            for (var i = 0; i < classes.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Reveal(
                index: 5 + i,
                child: _GroupClassChatCard(groupClass: classes[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Group class chat list for a client — shows only joined classes (AS-071).
class _ClientGroupChatList extends ConsumerWidget {
  const _ClientGroupChatList({required this.clientUid});

  final String clientUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final classesAsync = ref.watch(upcomingGroupClassesProvider);

    return classesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.errorGeneric),
      data: (classes) {
        if (classes.isEmpty) {
          return Text(
            l10n.noChatsYet,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        // Each tile checks isJoinedProvider and renders nothing if not joined.
        // Indices start at 5 so they fire within the section-header animation
        // window (≤708ms), keeping pumpAndSettle cascading in tests.
        return Column(
          children: [
            for (var i = 0; i < classes.length; i++)
              _JoinedGroupClassTile(
                groupClass: classes[i],
                clientUid: clientUid,
                revealIndex: 5 + i,
              ),
          ],
        );
      },
    );
  }
}

/// Renders a group-class chat card only when the client has joined that class.
/// Non-joined classes collapse to SizedBox.shrink() (AS-071).
class _JoinedGroupClassTile extends ConsumerWidget {
  const _JoinedGroupClassTile({
    required this.groupClass,
    required this.clientUid,
    required this.revealIndex,
  });

  final GroupClass groupClass;
  final String clientUid;
  final int revealIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJoinedAsync = ref.watch(
      isJoinedProvider((classId: groupClass.id, clientUid: clientUid)),
    );
    // Default to false until the stream resolves — avoids flicker.
    final isJoined = isJoinedAsync.asData?.value ?? false;

    if (!isJoined) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Reveal(
        index: revealIndex,
        child: _GroupClassChatCard(groupClass: groupClass),
      ),
    );
  }
}

/// Card for a group class chat entry.
/// Tapping navigates to the group chat thread screen for [groupClass.id].
class _GroupClassChatCard extends StatelessWidget {
  const _GroupClassChatCard({required this.groupClass});

  final GroupClass groupClass;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(groupClass.date);
    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: () => context.push('/chat/group/${groupClass.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kInkElevated,
                  border: Border.all(color: kLineDark, width: 1.2),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: kVolt,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupClass.title.toUpperCase(),
                      style: GoogleFonts.archivoBlack(
                        fontSize: 14,
                        color: kOffWhite,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr  '
                      '${groupClass.start}–${groupClass.end}',
                      style: GoogleFonts.interTight(
                        fontSize: 12,
                        color: kMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: kVolt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat.yMMMEd('sr_Latn').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}
