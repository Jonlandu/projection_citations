import 'package:flutter/material.dart';

import '../../features/editor/editor_page.dart';
import '../../features/help/help_page.dart';
import '../../features/history/history_page.dart';
import '../../features/welcome/welcome_page.dart';

enum AppNav { welcome, editor, history, help }

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.current,
    required this.child,
  });

  final String title;
  final AppNav current;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: _NavDrawer(current: current),
      body: Row(
        children: [
          // Permanent rail for wide screens
          LayoutBuilder(
            builder: (context, c) {
              if (MediaQuery.of(context).size.width < 980) return const SizedBox.shrink();
              return SizedBox(
                width: 240,
                child: _NavRail(current: current),
              );
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({required this.current});
  final AppNav current;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _NavList(current: current, isDrawer: true),
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({required this.current});
  final AppNav current;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: _NavList(current: current, isDrawer: false),
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  const _NavList({required this.current, required this.isDrawer});
  final AppNav current;
  final bool isDrawer;

  void _go(BuildContext context, AppNav nav) {
    Widget page;
    switch (nav) {
      case AppNav.welcome:
        page = const WelcomePage();
        break;
      case AppNav.editor:
        page = const EditorPage();
        break;
      case AppNav.history:
        page = const HistoryPage();
        break;
      case AppNav.help:
        page = const HelpPage();
        break;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        ListTile(
          title: const Text("ProjectionCitations"),
          subtitle: const Text("Offline Text Refactor"),
          leading: const Icon(Icons.text_fields),
          onTap: () => _go(context, AppNav.welcome),
        ),
        const Divider(),
        _item(context, AppNav.welcome, "Bienvenue", Icons.home_outlined),
        _item(context, AppNav.editor, "Éditeur", Icons.edit_note_outlined),
        _item(context, AppNav.history, "Historique", Icons.history_outlined),
        _item(context, AppNav.help, "Aide", Icons.help_outline),
      ],
    );
  }

  Widget _item(BuildContext context, AppNav nav, String label, IconData icon) {
    final selected = nav == current;
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        if (isDrawer) Navigator.of(context).pop();
        _go(context, nav);
      },
    );
  }
}
