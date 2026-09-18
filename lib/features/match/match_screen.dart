import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import '../../domain/models.dart';
import '../dna/dna_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  bool busy = false;
  Offset drag = Offset.zero;

  Future<void> decide(VoteDecision decision) async {
    final room = widget.controller.nextRoom;
    if (room == null || busy) return;
    setState(() => busy = true);
    await widget.controller.vote(
      roomId: room.id,
      decision: decision,
      operationId: 'vote-${room.id}',
    );
    if (mounted) {
      setState(() {
        busy = false;
        drag = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final room = widget.controller.nextRoom;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 110),
            children: [
              Text(
                'SpaceMatch',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: SpaceColors.sand),
              ),
              const SizedBox(height: 4),
              const Text(
                'Curta os espaços que combinam com você.',
                style: TextStyle(color: SpaceColors.muted),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    '${widget.controller.dna.evaluatedCount} ambientes avaliados',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (room == null)
                Container(
                  height: 480,
                  decoration: BoxDecoration(
                    color: SpaceColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: SpaceColors.outline),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.done_all,
                            size: 54,
                            color: SpaceColors.sand,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Você avaliou toda a seleção.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Seu SpaceDNA já pode ser consultado.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: SpaceColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onPanUpdate: busy
                      ? null
                      : (details) => setState(() => drag += details.delta),
                  onPanEnd: busy
                      ? null
                      : (_) {
                          if (drag.dx.abs() > 80) {
                            decide(
                              drag.dx > 0
                                  ? VoteDecision.like
                                  : VoteDecision.dislike,
                            );
                          } else {
                            setState(() => drag = Offset.zero);
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    transform: Matrix4.identity()
                      ..translateByDouble(drag.dx, 0, 0, 1)
                      ..rotateZ(drag.dx / 1800),
                    height: 480,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: AssetImage(room.assetPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xDD171715)],
                                stops: [.45, 1],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: [
                                  ...room.styles
                                      .take(2)
                                      .map((tag) => Chip(label: Text(tag))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                room.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              Text(
                                room.roomType,
                                style: const TextStyle(
                                  color: SpaceColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              if (room == null) ...[
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DnaScreen(controller: widget.controller),
                    ),
                  ),
                  icon: const Icon(Icons.insights_outlined),
                  label: const Text('Ver meu SpaceDNA'),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DecisionButton(
                    icon: Icons.close,
                    label: 'Não gostei',
                    onPressed: room == null || busy
                        ? null
                        : () => decide(VoteDecision.dislike),
                  ),
                  const SizedBox(width: 30),
                  _DecisionButton(
                    icon: Icons.favorite,
                    label: 'Gostei',
                    primary: true,
                    onPressed: room == null || busy
                        ? null
                        : () => decide(VoteDecision.like),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        icon: Icon(icon),
        iconSize: 28,
        style: IconButton.styleFrom(
          minimumSize: const Size(66, 66),
          backgroundColor: primary ? SpaceColors.sand : SpaceColors.field,
          foregroundColor: primary ? SpaceColors.onSand : SpaceColors.muted,
          side: BorderSide(
            color: primary ? SpaceColors.sand : SpaceColors.outline,
          ),
        ),
      ),
    );
  }
}
