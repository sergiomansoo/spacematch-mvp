import 'package:flutter/material.dart';

import '../core/design/space_theme.dart';
import '../features/auth/auth_screen.dart';
import '../features/shell/shell_screen.dart';
import 'app_controller.dart';

class SpaceMatchApp extends StatelessWidget {
  const SpaceMatchApp({
    super.key,
    required this.controller,
    this.isDemo = true,
  });
  final AppController controller;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpaceMatch',
      theme: SpaceTheme.dark,
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => controller.isAuthenticated
            ? ShellScreen(controller: controller, isDemo: isDemo)
            : AuthScreen(controller: controller),
      ),
    );
  }
}

class SpaceLogo extends StatelessWidget {
  const SpaceLogo({super.key, this.compact = false, this.wrap = false});
  final bool compact;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Container(
        width: compact ? 38 : 56,
        height: compact ? 38 : 56,
        decoration: BoxDecoration(
          color: SpaceColors.sand.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(compact ? 13 : 19),
          border: Border.all(color: SpaceColors.sand.withValues(alpha: .35)),
        ),
        child: Icon(
          Icons.auto_awesome,
          color: SpaceColors.sand,
          size: compact ? 20 : 27,
        ),
      ),
      Text(
        'SpaceMatch',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(color: SpaceColors.sand),
      ),
    ];
    if (wrap) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [children[0], const SizedBox(width: 12), children[1]],
    );
  }
}

class SpaceCard extends StatelessWidget {
  const SpaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
