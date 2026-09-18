import 'models.dart';

class DnaCalculator {
  const DnaCalculator();

  SpaceDna calculate({
    required List<RoomReference> rooms,
    required Map<String, VoteDecision> votes,
    required int revision,
  }) {
    return SpaceDna(
      revision: revision,
      evaluatedCount: votes.length,
      styles: _dimension(rooms, votes, (room) => room.styles, 2),
      materials: _dimension(rooms, votes, (room) => room.materials, 3),
      palettes: _dimension(rooms, votes, (room) => room.palettes, 3),
    );
  }

  List<Affinity> _dimension(
    List<RoomReference> rooms,
    Map<String, VoteDecision> votes,
    List<String> Function(RoomReference) tags,
    int limit,
  ) {
    final counts = <String, List<int>>{};
    for (final room in rooms) {
      final vote = votes[room.id];
      if (vote == null) continue;
      for (final tag in tags(room).toSet()) {
        final pair = counts.putIfAbsent(tag, () => [0, 0]);
        pair[vote == VoteDecision.like ? 0 : 1]++;
      }
    }
    final result =
        counts.entries
            .where((entry) => entry.value[0] >= 2)
            .map((entry) {
              final likes = entry.value[0];
              final dislikes = entry.value[1];
              return Affinity(
                label: entry.key,
                score: (likes - dislikes) / (likes + dislikes),
                likes: likes,
                dislikes: dislikes,
              );
            })
            .where((item) => item.score > 0)
            .toList()
          ..sort((a, b) {
            final score = b.score.compareTo(a.score);
            if (score != 0) return score;
            final likes = b.likes.compareTo(a.likes);
            return likes != 0 ? likes : a.label.compareTo(b.label);
          });
    return result.take(limit).toList();
  }
}
