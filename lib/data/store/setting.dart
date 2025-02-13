import 'dart:convert';

import 'package:fl_lib/fl_lib.dart';
import 'package:server_box/data/model/app/menu/server_func.dart';
import 'package:server_box/data/model/app/server_detail_card.dart';
import 'package:server_box/data/model/ssh/virtual_key.dart';

import 'package:server_box/data/model/app/net_view.dart';
import 'package:server_box/data/res/default.dart';

class SettingStore extends HiveStore {
  SettingStore._() : super('setting');

  static final instance = SettingStore._();

  // ------BEGIN------
  //
  // These settings are not displayed in the settings page
  // You can edit them in the settings json editor (by long press the settings
  // item in the drawer of the home page)

  /// Discussion #146
  late final serverTabUseOldUI = propertyDefault('serverTabUseOldUI', false);

  /// Time out for server connect and more...
  late final timeout = propertyDefault('timeOut', 5);

  /// Record history of SFTP path and etc.
  late final recordHistory = propertyDefault('recordHistory', true);

  /// Lanch page idx
  // late final launchPage = property('launchPage', Defaults.launchPageIdx);

  /// Disk view: amount / IO
  late final serverTabPreferDiskAmount = propertyDefault(
    'serverTabPreferDiskAmount',
    false,
  );

  // ------END------

  /// Bigger for bigger font size
  /// 1.0 means 100%
  /// Warning: This may cause some UI issues
  late final textFactor = propertyDefault('textFactor', 1.0);

  /// The seed of color scheme
  late final colorSeed = propertyDefault('primaryColor', 4287106639);

  late final serverStatusUpdateInterval = propertyDefault(
    'serverStatusUpdateInterval',
    Defaults.updateInterval,
  );

  // Max retry count when connect to server
  late final maxRetryCount = propertyDefault('maxRetryCount', 2);

  // Night mode: 0 -> auto, 1 -> light, 2 -> dark, 3 -> AMOLED, 4 -> AUTO-AMOLED
  late final themeMode = propertyDefault('themeMode', 0);

  // Font file path
  late final fontPath = propertyDefault('fontPath', '');

  // Backgroud running (Android)
  late final bgRun = propertyDefault('bgRun', isAndroid);

  // Server order
  late final serverOrder = propertyDefault<List<String>>('serverOrder', []);

  late final snippetOrder = propertyDefault<List<String>>('snippetOrder', []);

  // Server details page cards order
  late final detailCardOrder = propertyDefault(
    'detailCardOrder',
    ServerDetailCards.values.map((e) => e.name).toList(),
  );

  // SSH term font size
  late final termFontSize = propertyDefault('termFontSize', 13.0);

  // Locale
  late final locale = propertyDefault('locale', '');

  // SSH virtual key (ctrl | alt) auto turn off
  late final sshVirtualKeyAutoOff =
      propertyDefault('sshVirtualKeyAutoOff', true);

  late final editorFontSize = propertyDefault('editorFontSize', 12.5);

  // Editor theme
  late final editorTheme = propertyDefault('editorTheme', Defaults.editorTheme);

  late final editorDarkTheme =
      propertyDefault('editorDarkTheme', Defaults.editorDarkTheme);

  late final fullScreen = propertyDefault('fullScreen', false);

  late final fullScreenJitter = propertyDefault('fullScreenJitter', true);

  // late final fullScreenRotateQuarter = property(
  //   'fullScreenRotateQuarter',
  //   1,
  // );

  // late final keyboardType = property(
  //   'keyboardType',
  //   TextInputType.text.index,
  // );

  late final sshVirtKeys = propertyDefault(
    'sshVirtKeys',
    VirtKeyX.defaultOrder.map((e) => e.index).toList(),
  );

  late final netViewType = propertyDefault('netViewType', NetViewType.speed);

  // Only valid on iOS
  late final autoUpdateHomeWidget =
      propertyDefault('autoUpdateHomeWidget', isIOS);

  late final autoCheckAppUpdate = propertyDefault('autoCheckAppUpdate', true);

  /// Display server tab function buttons on the bottom of each server card if [true]
  ///
  /// Otherwise, display them on the top of server detail page
  late final moveServerFuncs =
      propertyDefault('moveOutServerTabFuncBtns', false);

  /// Whether use `rm -r` to delete directory on SFTP
  late final sftpRmrDir = propertyDefault('sftpRmrDir', false);

  /// Whether use system's primary color as the app's primary color
  late final useSystemPrimaryColor =
      propertyDefault('useSystemPrimaryColor', false);

  /// Only valid on iOS / Android / Windows
  late final useBioAuth = propertyDefault('useBioAuth', false);

  /// Delay to lock the App with BioAuth
  late final delayBioAuthLock = property('delayBioAuthLock', false);

  /// The performance of highlight is bad
  late final editorHighlight = propertyDefault('editorHighlight', true);

  /// Open SFTP with last viewed path
  late final sftpOpenLastPath = propertyDefault('sftpOpenLastPath', true);

  /// Show folders first in SFTP file browser
  late final sftpShowFoldersFirst =
      propertyDefault('sftpShowFoldersFirst', true);

  /// Show tip of suspend
  late final showSuspendTip = propertyDefault('showSuspendTip', true);

  /// Whether collapse UI items by default
  late final collapseUIDefault = propertyDefault('collapseUIDefault', true);

  late final serverFuncBtns = propertyDefault(
    'serverBtns',
    ServerFuncBtn.defaultIdxs,
  );

  /// Docker is more popular than podman, set to `false` to use docker
  late final usePodman = propertyDefault('usePodman', false);

  /// Try to use `sudo` to run docker command
  late final containerTrySudo = propertyDefault('containerTrySudo', true);

  /// Keep previous server status when err occurs
  late final keepStatusWhenErr = propertyDefault('keepStatusWhenErr', false);

  /// Parse container stat
  late final containerParseStat = propertyDefault('containerParseStat', true);

  /// Auto refresh container status
  late final contaienrAutoRefresh =
      propertyDefault('contaienrAutoRefresh', true);

  /// Use double column servers page on Desktop
  late final doubleColumnServersPage = propertyDefault(
    'doubleColumnServersPage',
    true,
  );

  /// Ignore local network device (eg: br-xxx, ovs-system...)
  /// when building traffic view on server tab
  //late final ignoreLocalNet = propertyDefault('ignoreLocalNet', true);

  /// Remerber pwd in memory
  /// Used for [DialogX.showPwdDialog]
  late final rememberPwdInMem = propertyDefault('rememberPwdInMem', true);

  /// SSH Term Theme
  /// 0: follow app theme, 1: light, 2: dark
  late final termTheme = propertyDefault('termTheme', 0);

  /// Compatiablity for Chinese Android.
  /// Set it to true, if you use Safe Keyboard on Chinese Android
  // late final cnKeyboardComp = propertyDefault('cnKeyboardComp', false);

  late final lastVer = propertyDefault('lastVer', 0);

  /// Use CupertinoPageRoute for all routes
  late final cupertinoRoute = propertyDefault('cupertinoRoute', isIOS);

  /// Hide title bar on desktop
  late final hideTitleBar = propertyDefault('hideTitleBar', isDesktop);

  /// Display CPU view as progress, also called as old CPU view
  late final cpuViewAsProgress = propertyDefault('cpuViewAsProgress', false);

  late final displayCpuIndex = propertyDefault('displayCpuIndex', true);

  late final editorSoftWrap = propertyDefault('editorSoftWrap', isIOS);

  late final sshTermHelpShown = propertyDefault('sshTermHelpShown', false);

  late final horizonVirtKey = propertyDefault('horizonVirtKey', false);

  /// general wake lock
  late final generalWakeLock = propertyDefault('generalWakeLock', false);

  /// ssh page
  late final sshWakeLock = propertyDefault('sshWakeLock', true);

  /// fmt: https://example.com/{DIST}-{BRIGHT}.png
  late final serverLogoUrl = propertyDefault('serverLogoUrl', '');

  late final betaTest = propertyDefault('betaTest', false);

  /// For desktop only.
  /// Record the position and size of the window.
  late final windowState = property<WindowState>(
    'windowState',
    fromStr: (jsonStr) =>
        WindowState.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    toStr: (state) => state == null ? null : jsonEncode(state.toJson()),
  );

  late final introVer = propertyDefault('introVer', 0);

  late final letterCache = propertyDefault('letterCache', false);

  /// Set it to `$EDITOR`, `vim` and etc. to use remote system editor in SSH terminal.
  /// Set it empty to use local editor GUI.
  late final sftpEditor = propertyDefault('sftpEditor', '');

  /// Run foreground service on Android, if the SSH terminal is running
  late final fgService = propertyDefault('fgService', false);

  /// Close the editor after saving
  late final closeAfterSave = propertyDefault('closeAfterSave', false);

  // Never show these settings for users
  //
  // ------BEGIN------

  /// Version of store db
  late final storeVersion = propertyDefault('storeVersion', 0);

  /// Have notified user for notificaiton permission or not
  late final noNotiPerm = propertyDefault('noNotiPerm', false);

  // ------END------
}
