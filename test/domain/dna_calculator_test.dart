import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/domain/dna_calculator.dart';
import 'package:spacematch_mvp/domain/models.dart';

void main() {
  const calculator = DnaCalculator();

  test('calcula afinidade auditável e exige duas curtidas', () {
    final rooms = [
      room('a', styles: ['Minimalista'], materials: ['Madeira']),
      room('b', styles: ['Minimalista'], materials: ['Madeira']),
      room('c', styles: ['Minimalista'], materials: ['Concreto']),
      room('d', styles: ['Minimalista'], materials: ['Madeira']),
      room('e', styles: ['Industrial'], materials: ['Metal']),
    ];
    final votes = {
      'a': VoteDecision.like,
      'b': VoteDecision.like,
      'c': VoteDecision.like,
      'd': VoteDecision.dislike,
      'e': VoteDecision.like,
    };

    final dna = calculator.calculate(rooms: rooms, votes: votes, revision: 5);

    expect(dna.revision, 5);
    expect(dna.evaluatedCount, 5);
    expect(dna.styles.single.label, 'Minimalista');
    expect(dna.styles.single.percent, 50);
    expect(dna.materials.single.label, 'Madeira');
    expect(dna.materials.single.percent, 33);
    expect(dna.styles.any((item) => item.label == 'Industrial'), isFalse);
  });

  test('mantém dimensão vazia quando não há evidência positiva suficiente', () {
    final dna = calculator.calculate(
      rooms: [
        room('a', palettes: ['Areia']),
      ],
      votes: const {'a': VoteDecision.like},
      revision: 1,
    );

    expect(dna.palettes, isEmpty);
    expect(dna.isDefined, isFalse);
  });
}

RoomReference room(
  String id, {
  List<String> styles = const [],
  List<String> materials = const [],
  List<String> palettes = const [],
}) => RoomReference(
  id: id,
  title: id,
  roomType: 'Sala',
  assetPath: 'assets/images/room_01.jpg',
  styles: styles,
  materials: materials,
  palettes: palettes,
);
