import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import '../../domain/models.dart';

class DnaScreen extends StatelessWidget {
  const DnaScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu SpaceDNA')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              Container(
                height: 290,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/room_02.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0x88171715),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Chip(
                      avatar: Icon(Icons.auto_awesome, size: 17),
                      label: Text('DNA PRINCIPAL'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.dna.isDefined
                          ? controller.dna.styles
                                .map((item) => item.label)
                                .join(' + ')
                          : 'Em descoberta',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      '${controller.dna.evaluatedCount} ambientes avaliados',
                      style: const TextStyle(color: SpaceColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (!controller.dna.isDefined)
                const SpaceCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        color: SpaceColors.sand,
                        size: 36,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Ainda estamos conhecendo suas preferências.',
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Curta ao menos duas referências com elementos parecidos para revelar uma afinidade.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SpaceColors.muted),
                      ),
                    ],
                  ),
                )
              else ...[
                _AffinitySection(
                  title: 'Estilos',
                  icon: Icons.style_outlined,
                  values: controller.dna.styles,
                ),
                const SizedBox(height: 14),
                _AffinitySection(
                  title: 'Materiais',
                  icon: Icons.texture_outlined,
                  values: controller.dna.materials,
                ),
                const SizedBox(height: 14),
                _AffinitySection(
                  title: 'Paleta de cores',
                  icon: Icons.palette_outlined,
                  values: controller.dna.palettes,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AffinitySection extends StatelessWidget {
  const _AffinitySection({
    required this.title,
    required this.icon,
    required this.values,
  });
  final String title;
  final IconData icon;
  final List<Affinity> values;

  @override
  Widget build(BuildContext context) {
    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SpaceColors.sand),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 18),
          if (values.isEmpty)
            const Text(
              'Ainda não identificado',
              style: TextStyle(color: SpaceColors.muted),
            ),
          ...values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.label)),
                      Text(
                        '${item.percent}%',
                        style: const TextStyle(
                          color: SpaceColors.sand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: item.score,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: SpaceColors.field,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
