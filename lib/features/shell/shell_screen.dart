import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';
import 'mvp_screens.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.controller, this.isDemo = true});
  final AppController controller;
  final bool isDemo;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        controller: widget.controller,
        isDemo: widget.isDemo,
        openTab: (value) => setState(() => index = value),
      ),
      MatchScreen(controller: widget.controller),
      CreateScreen(
        controller: widget.controller,
        onProjectCreated: () => setState(() => index = 3),
      ),
      ProjectsScreen(controller: widget.controller),
    ];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: SpaceColors.surface.withValues(alpha: .97),
            border: Border.all(color: SpaceColors.outline),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: Colors.transparent,
            indicatorColor: SpaceColors.sand.withValues(alpha: .14),
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style),
                label: 'Match',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Criar',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Projetos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
