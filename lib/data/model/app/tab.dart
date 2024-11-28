import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:server_box/core/extension/context/locale.dart';
import 'package:server_box/view/page/server/tab.dart';
import 'package:server_box/view/page/setting/entry.dart';
import 'package:server_box/view/page/snippet/list.dart';
import 'package:server_box/view/page/ssh/tab.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:server_box/view/page/storage/local.dart';

enum AppTab {
  server,
  ssh,
  file,
  snippet,
  settings,
  ;

  Widget get page {
    return switch (this) {
      server => const ServerPage(),
      settings => const SettingsPage(),
      ssh => const SSHTabPage(),
      file => const LocalFilePage(),
      snippet => const SnippetListPage(),
    };
  }

  NavigationDestination get navDestination {
    return switch (this) {
      server => NavigationDestination(
          icon: const Icon(BoxIcons.bx_server),
          label: l10n.server,
          selectedIcon: const Icon(BoxIcons.bxs_server),
        ),
      settings => NavigationDestination(
          icon: const Icon(Icons.settings),
          label: libL10n.setting,
          selectedIcon: const Icon(Icons.settings),
        ),
      ssh => const NavigationDestination(
          icon: Icon(Icons.terminal_outlined),
          label: 'SSH',
          selectedIcon: Icon(Icons.terminal),
        ),
      snippet => NavigationDestination(
          icon: const Icon(Icons.code),
          label: l10n.snippet,
          selectedIcon: const Icon(Icons.code),
        ),
      file => NavigationDestination(
          icon: const Icon(Icons.folder_open),
          label: libL10n.file,
          selectedIcon: const Icon(Icons.folder),
        ),
    };
  }

  static List<NavigationDestination> get navDestinations {
    return AppTab.values.map((e) => e.navDestination).toList();
  }

  static List<NavigationRailDestination> get navRailDestinations {
    return AppTab.values
        .map((e) => NavigationRailDestination(
        icon: e.navDestination.icon,
        label: Text(e.navDestination.label),
        selectedIcon: e.navDestination.selectedIcon))
        .toList();
  }
}
