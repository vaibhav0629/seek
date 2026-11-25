import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/round_robin.dart';

/// Membuat jadwal round robin dari RSVP status [going] lalu menyimpan ke repo.
class GenerateScheduleButton extends ConsumerStatefulWidget {
  const GenerateScheduleButton({
    super.key,
    required this.meetId,
    required this.sport,
    required this.rsvps,
  });

  final String meetId;
  final String sport;
  final List<Rsvp> rsvps;

  @override
  ConsumerState<GenerateScheduleButton> createState() =>
      _GenerateScheduleButtonState();
}

class _GenerateScheduleButtonState extends ConsumerState<GenerateScheduleButton> {
  var _busy = false;

  Future<void> _generate() async {
    final playerIds = goingPlayerIdsFromRsvps(widget.rsvps);
    if (playerIds.length < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 2 peserta dengan status going untuk jadwal.'),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final matches = generateMeetRoundRobin(
        meetId: widget.meetId,
        sport: widget.sport,
        playerIds: playerIds,
      );
      if (matches.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada match yang bisa dibuat.')),
        );
        return;
      }
      await ref.read(matchRepositoryProvider).saveMatches(matches);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal dibuat (${matches.length} match).')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat jadwal: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goingCount =
        widget.rsvps.where((r) => r.status == RsvpStatus.going).length;

    return FilledButton.icon(
      onPressed: _busy || goingCount < 2 ? null : _generate,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.event_note),
      label: Text(_busy ? 'Membuat jadwal...' : 'Generate jadwal round robin'),
    );
  }
}
