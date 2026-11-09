import 'package:flutter/material.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';

Future<void> showScoreInputSheet({
  required BuildContext context,
  required GameMatch match,
  required Map<String, String> playerNames,
  required Future<void> Function(int scoreA, int scoreB) onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ScoreInputSheet(
        match: match,
        playerNames: playerNames,
        onSubmit: onSubmit,
      ),
    ),
  );
}

class ScoreInputSheet extends StatefulWidget {
  const ScoreInputSheet({
    super.key,
    required this.match,
    required this.playerNames,
    required this.onSubmit,
  });

  final GameMatch match;
  final Map<String, String> playerNames;
  final Future<void> Function(int scoreA, int scoreB) onSubmit;

  @override
  State<ScoreInputSheet> createState() => _ScoreInputSheetState();
}

class _ScoreInputSheetState extends State<ScoreInputSheet> {
  late int _a = widget.match.scoreA ?? 0;
  late int _b = widget.match.scoreB ?? 0;
  bool _saving = false;

  // Match turnamen harus ada pemenang, round robin boleh seri.
  bool get _isTournament => widget.match.competitionId != null;
  bool get _drawNotAllowed => _isTournament && _a == _b;

  Widget _counter(String label, int value, ValueChanged<int> onChanged) {
    return Expanded(
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSubmit(_a, _b);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Input skor', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _counter(
                  teamLabel(widget.match.teamA, widget.playerNames),
                  _a,
                  (v) => setState(() => _a = v),
                ),
                _counter(
                  teamLabel(widget.match.teamB, widget.playerNames),
                  _b,
                  (v) => setState(() => _b = v),
                ),
              ],
            ),
            if (_drawNotAllowed)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Match turnamen tidak boleh seri.'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_saving || _drawNotAllowed) ? null : _save,
                child: Text(_saving ? 'Menyimpan...' : 'Simpan skor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
