import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import '../dna/dna_screen.dart';
import '../projects/projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.openTab,
  });
  final AppController controller;
  final ValueChanged<int> openTab;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Olá, ${controller.email?.split('@').first ?? 'você'}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Conta',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AccountScreen(controller: controller),
                    ),
                  ),
                  icon: const Icon(Icons.person_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 205,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: SpaceColors.sand.withValues(alpha: .28),
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/room_01.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99262319),
                    BlendMode.darken,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: SpaceColors.sand,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SPACEDNA',
                        style: TextStyle(
                          color: SpaceColors.sand,
                          fontSize: 11,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.dna.isDefined
                        ? controller.dna.styles
                              .map((item) => item.label)
                              .join(' + ')
                        : 'Descubra o seu estilo',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${controller.dna.evaluatedCount} ambientes avaliados',
                    style: const TextStyle(color: SpaceColors.muted),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DnaScreen(controller: controller),
                  ),
                ),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Ver meu SpaceDNA'),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'O que vamos transformar hoje?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => openTab(2),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Transformar meu ambiente'),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Projetos recentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => openTab(3),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (controller.projects.isEmpty)
              SpaceCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.chair_outlined,
                      size: 36,
                      color: SpaceColors.sand,
                    ),
                    const SizedBox(height: 10),
                    const Text('Seu primeiro projeto começa com uma foto.'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => openTab(2),
                      child: const Text('Criar projeto'),
                    ),
                  ],
                ),
              )
            else
              ...controller.projects
                  .take(2)
                  .map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ProjectTile(
                        project: project,
                        onTap: () =>
                            openProject(context, controller, project.id),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SpaceLogo(compact: true),
            const SizedBox(height: 28),
            SpaceCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(controller.email ?? ''),
                subtitle: const Text('Conta local de demonstração'),
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir conta?'),
                    content: const Text(
                      'Todos os votos e projetos locais serão removidos deste dispositivo.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  Navigator.of(context).pop();
                  await controller.deleteAccount();
                }
              },
              child: const Text(
                'Excluir conta',
                style: TextStyle(color: SpaceColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
