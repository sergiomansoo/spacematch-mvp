import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import '../../domain/models.dart';

Future<void> openProject(
  BuildContext context,
  AppController controller,
  String projectId,
) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ProjectDetailScreen(controller: controller, projectId: projectId),
    ),
  );
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus projetos')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SafeArea(
          child: controller.projects.isEmpty
              ? const _EmptyProjects()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 116),
                  itemCount: controller.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final project = controller.projects[index];
                    return ProjectTile(
                      project: project,
                      onTap: () => openProject(context, controller, project.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.space_dashboard_outlined,
              size: 52,
              color: SpaceColors.sand,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum projeto ainda',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use a aba Criar para transformar a primeira foto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SpaceColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  const ProjectTile({super.key, required this.project, required this.onTap});
  final SpaceProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SpaceColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SpaceColors.outline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox.square(
                dimension: 86,
                child: SpaceImage(
                  path: project.resultAssetPath ?? project.sourceAssetPath,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.roomType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  _StatusLabel(status: project.status),
                  const SizedBox(height: 6),
                  Text(
                    project.savedAt == null
                        ? 'Toque para visualizar'
                        : 'Projeto salvo',
                    style: const TextStyle(
                      color: SpaceColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SpaceColors.muted),
          ],
        ),
      ),
    );
  }
}

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.controller,
    required this.projectId,
  });

  final AppController controller;
  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  double reveal = .52;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final project = widget.controller.projectById(widget.projectId);
        return Scaffold(
          appBar: AppBar(title: Text('Projeto · ${project.roomType}')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
              children: [
                if (project.status == ProjectStatus.succeeded &&
                    project.resultAssetPath != null)
                  _BeforeAfter(
                    source: project.sourceAssetPath,
                    result: project.resultAssetPath!,
                    reveal: reveal,
                    onChanged: (value) => setState(() => reveal = value),
                  )
                else
                  _PendingResult(project: project),
                const SizedBox(height: 18),
                SpaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Conceito proposto',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          _StatusLabel(status: project.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.description.isEmpty
                            ? 'Composição equilibrada em tons naturais, texturas acolhedoras e iluminação suave.'
                            : project.description,
                        style: const TextStyle(
                          color: SpaceColors.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text('Tons naturais')),
                          Chip(label: Text('Madeira')),
                          Chip(label: Text('Luz indireta')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (project.status == ProjectStatus.failed)
                  FilledButton.icon(
                    onPressed: widget.controller.isBusy
                        ? null
                        : () => widget.controller.retryProject(project.id),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  )
                else
                  FilledButton.icon(
                    onPressed: project.status == ProjectStatus.succeeded
                        ? () async {
                            await widget.controller.saveProject(project.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Projeto salvo neste dispositivo.',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: Icon(
                      project.savedAt == null
                          ? Icons.bookmark_border
                          : Icons.bookmark,
                    ),
                    label: Text(
                      project.savedAt == null
                          ? 'Salvar projeto'
                          : 'Projeto salvo',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BeforeAfter extends StatelessWidget {
  const _BeforeAfter({
    required this.source,
    required this.result,
    required this.reveal,
    required this.onChanged,
  });

  final String source;
  final String result;
  final double reveal;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Antes e depois',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Arraste o controle para comparar.',
          style: TextStyle(color: SpaceColors.muted),
        ),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: .82,
          child: LayoutBuilder(
            builder: (context, constraints) => ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  onChanged(
                    (details.localPosition.dy / constraints.maxHeight).clamp(
                      0.04,
                      .96,
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SpaceImage(path: result),
                    ClipRect(
                      clipper: _RevealClipper(reveal),
                      child: SpaceImage(path: source),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: constraints.maxHeight * reveal - 1,
                      child: Container(height: 2, color: Colors.white),
                    ),
                    Positioned(
                      left: constraints.maxWidth / 2 - 20,
                      top: constraints.maxHeight * reveal - 20,
                      child: const CircleAvatar(
                        backgroundColor: SpaceColors.sand,
                        foregroundColor: SpaceColors.onSand,
                        child: Icon(Icons.compare_arrows),
                      ),
                    ),
                    const Positioned(
                      left: 14,
                      top: 14,
                      child: _ImageLabel('ANTES'),
                    ),
                    const Positioned(
                      right: 14,
                      top: 14,
                      child: _ImageLabel('DEPOIS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper(this.reveal);
  final double reveal;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width, size.height * reveal);

  @override
  bool shouldReclip(_RevealClipper oldClipper) => reveal != oldClipper.reveal;
}

class _ImageLabel extends StatelessWidget {
  const _ImageLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xB3171715),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PendingResult extends StatelessWidget {
  const _PendingResult({required this.project});
  final SpaceProject project;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .9,
      child: SpaceCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              project.status == ProjectStatus.failed
                  ? Icons.error_outline
                  : Icons.auto_awesome,
              color: project.status == ProjectStatus.failed
                  ? SpaceColors.error
                  : SpaceColors.sand,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              project.status == ProjectStatus.failed
                  ? 'Não foi possível criar a proposta'
                  : 'Criando sua proposta',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              project.errorMessage ??
                  'Isso deve levar apenas alguns instantes.',
              style: const TextStyle(color: SpaceColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProjectStatus.succeeded => ('PRONTO', SpaceColors.success),
      ProjectStatus.failed => ('ERRO', SpaceColors.error),
      ProjectStatus.processing => ('CRIANDO', SpaceColors.sand),
    };
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        letterSpacing: 1.3,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SpaceImage extends StatelessWidget {
  const SpaceImage({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) return Image.asset(path, fit: BoxFit.cover);
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: SpaceColors.field,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: SpaceColors.muted),
        ),
      ),
    );
  }
}
