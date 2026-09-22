import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A secondary page whose title can grow with the system text size.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge!;
    final painter = TextPainter(
      text: TextSpan(text: title, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: math.max(1, MediaQuery.sizeOf(context).width - 96));
    final toolbarHeight = math.max(kToolbarHeight, painter.height + 24);
    painter.dispose();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: toolbarHeight,
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          title,
          style: style,
          softWrap: true,
          overflow: TextOverflow.visible,
          textScaler: MediaQuery.textScalerOf(context),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

class AboutHeading extends StatelessWidget {
  const AboutHeading(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: style ?? Theme.of(context).textTheme.titleLarge),
  );
}
