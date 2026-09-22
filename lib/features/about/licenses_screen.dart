import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import 'about_widgets.dart';

Future<List<LicenseEntry>> loadAppLicenses() =>
    LicenseRegistry.licenses.toList();

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key, this.loadLicenses = loadAppLicenses});

  final Future<List<LicenseEntry>> Function() loadLicenses;

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late Future<List<LicenseEntry>> _licenses = Future.sync(widget.loadLicenses);

  @override
  Widget build(BuildContext context) => AboutPage(
    title: 'Licenças de código aberto',
    child: FutureBuilder<List<LicenseEntry>>(
      future: _licenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _Status('Carregando licenças…');
        }
        if (snapshot.hasError) {
          return _Status(
            'Não foi possível carregar as licenças.',
            retry: () => setState(() {
              _licenses = Future.sync(widget.loadLicenses);
            }),
          );
        }
        final licenses = snapshot.data ?? const <LicenseEntry>[];
        if (licenses.isEmpty) {
          return const _Status('Nenhuma licença disponível nesta versão.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: licenses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final license = licenses[index];
            return SpaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AboutHeading(license.packages.join(', ')),
                  const SizedBox(height: 16),
                  for (final paragraph in license.paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        paragraph.text,
                        textAlign:
                            paragraph.indent == LicenseParagraph.centeredIndent
                            ? TextAlign.center
                            : TextAlign.start,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status(this.message, {this.retry});

  final String message;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
    child: SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          if (retry != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: retry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ],
      ),
    ),
  );
}
