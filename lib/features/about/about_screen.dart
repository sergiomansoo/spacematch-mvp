import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../core/design/space_theme.dart';
import '../../data/app_info_service.dart';
import 'about_widgets.dart';
import 'licenses_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({
    super.key,
    this.loadAppInfo = AppInfoService.load,
    this.isDemo = true,
  });

  final Future<AppInfo> Function() loadAppInfo;
  final bool isDemo;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<AppInfo> _info = Future.sync(widget.loadAppInfo);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AboutPage(
      title: 'Sobre o app',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceLogo(wrap: true),
            const SizedBox(height: 24),
            AboutHeading(
              'Seu espaço, do seu jeito.',
              style: text.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'O SpaceMatch ajuda você a descobrir seu estilo de decoração, '
              'explorar possibilidades para seus ambientes e guardar suas ideias em projetos.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 24),
            const SpaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AboutHeading('Como funciona'),
                  SizedBox(height: 16),
                  _Feature(
                    icon: Icons.style_outlined,
                    title: 'Match',
                    description:
                        'Avalie ambientes e descubra o que combina com você.',
                  ),
                  SizedBox(height: 16),
                  _Feature(
                    icon: Icons.insights_outlined,
                    title: 'SpaceDNA',
                    description: 'Veja seu perfil de preferências evoluir a cada escolha.',
                  ),
                  SizedBox(height: 16),
                  _Feature(
                    icon: Icons.folder_outlined,
                    title: 'Projetos',
                    description: 'Explore uma proposta para seu ambiente, compare o antes e depois e salve o resultado.',
                  ),
                ],
              ),
            ),
            if (widget.isDemo) ...[
              const SizedBox(height: 24),
              SpaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AboutHeading('Sobre esta versão'),
                    const SizedBox(height: 8),
                    Text(
                      'Esta é uma versão de demonstração. Os dados ficam neste dispositivo '
                      'e as propostas visuais usam imagens de exemplo incluídas no app.',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SpaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AboutHeading('Informações'),
                        const SizedBox(height: 16),
                        Text('Versão', style: text.titleMedium),
                        const SizedBox(height: 8),
                        FutureBuilder<AppInfo>(
                          future: _info,
                          builder: (context, snapshot) => Text(
                            snapshot.connectionState != ConnectionState.done
                                ? 'Carregando versão…'
                                : snapshot.data?.label ?? 'Versão indisponível',
                            style: text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: SpaceColors.outline),
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings: const RouteSettings(
                            name: '/about/licenses',
                          ),
                          builder: (_) => const LicensesScreen(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Licenças de código aberto',
                                style: text.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.chevron_right,
                                color: SpaceColors.sand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 24, color: SpaceColors.sand)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AboutHeading(title, style: text.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
