import 'package:fl_lib/fl_lib.dart';
import 'package:server_box/data/model/app/menu/server_func.dart';
import 'package:server_box/data/model/app/server_detail_card.dart';
import 'package:server_box/data/model/ssh/virtual_key.dart';

import 'package:server_box/data/model/app/net_view.dart';
import 'package:server_box/data/res/default.dart';

class SettingStore extends PersistentStore {
  SettingStore._() : super('setting');

  static final instance = SettingStore._();

  // ------BEGIN------
  //
  // These settings are not displayed in the settings page
  // You can edit them in the settings json editor (by long press the settings
  // item in the drawer of the home page)

  /// Discussion #146
  late final serverTabUseOldUI = property('serverTabUseOldUI', false);

  /// Time out for server connect and more...
  late final timeout = property('timeOut', 5);

  /// Record history of SFTP path and etc.
  late final recordHistory = property('recordHistory', true);

  /// Lanch page idx
  // late final launchPage = property('launchPage', Defaults.launchPageIdx);

  /// Disk view: amount / IO
  late final serverTabPreferDiskAmount = property(
    'serverTabPreferDiskAmount',
    false,
  );

  // ------END------

  /// Bigger for bigger font size
  /// 1.0 means 100%
  /// Warning: This may cause some UI issues
  late final textFactor = property('textFactor', 1.0);

  /// The seed of color scheme
  late final colorSeed = property('primaryColor', 4287106639);

  late final serverStatusUpdateInterval = property(
    'serverStatusUpdateInterval',
    Defaults.updateInterval,
  );

  // Max retry count when connect to server
  late final maxRetryCount = property('maxRetryCount', 2);

  // Night mode: 0 -> auto, 1 -> light, 2 -> dark, 3 -> AMOLED, 4 -> AUTO-AMOLED
  late final themeMode = property('themeMode', 0);

  // Font file path
  late final fontPath = property('fontPath', '');

  // Backgroud running (Android)
  late final bgRun = property('bgRun', isAndroid);

  // Server order
  late final serverOrder = listProperty<String>('serverOrder', []);

  late final snippetOrder = listProperty<String>('snippetOrder', []);

  // Server details page cards order
  late final detailCardOrder = listProperty(
    'detailCardOrder',
    ServerDetailCards.values.map((e) => e.name).toList(),
  );

  // SSH term font size
  late final termFontSize = property('termFontSize', 13.0);

  // Locale
  late final locale = property('locale', '');

  // SSH virtual key (ctrl | alt) auto turn off
  late final sshVirtualKeyAutoOff = property('sshVirtualKeyAutoOff', true);

  late final editorFontSize = property('editorFontSize', 12.5);

  // Editor theme
  late final editorTheme = property('editorTheme', Defaults.editorTheme);

  late final editorDarkTheme =
      property('editorDarkTheme', Defaults.editorDarkTheme);

  late final fullScreen = property('fullScreen', false);

  late final fullScreenJitter = property('fullScreenJitter', true);

  // late final fullScreenRotateQuarter = property(
  //   'fullScreenRotateQuarter',
  //   1,
  // );

  // late final keyboardType = property(
  //   'keyboardType',
  //   TextInputType.text.index,
  // );

  late final sshVirtKeys = listProperty(
    'sshVirtKeys',
    VirtKeyX.defaultOrder.map((e) => e.index).toList(),
  );

  late final netViewType = property('netViewType', NetViewType.speed);

  // Only valid on iOS
  late final autoUpdateHomeWidget = property('autoUpdateHomeWidget', isIOS);

  late final autoCheckAppUpdate = property('autoCheckAppUpdate', true);

  /// Display server tab function buttons on the bottom of each server card if [true]
  ///
  /// Otherwise, display them on the top of server detail page
  late final moveServerFuncs = property('moveOutServerTabFuncBtns', false);

  /// Whether use `rm -r` to delete directory on SFTP
  late final sftpRmrDir = property('sftpRmrDir', false);

  /// Whether use system's primary color as the app's primary color
  late final useSystemPrimaryColor = property('useSystemPrimaryColor', false);

  /// Only valid on iOS / Android / Windows
  late final useBioAuth = property('useBioAuth', false);

  /// Delay to lock the App with BioAuth
  late final delayBioAuthLock = property('delayBioAuthLock', false);

  /// The performance of highlight is bad
  late final editorHighlight = property('editorHighlight', true);

  /// Open SFTP with last viewed path
  late final sftpOpenLastPath = property('sftpOpenLastPath', true);

  /// Show folders first in SFTP file browser
  late final sftpShowFoldersFirst = property('sftpShowFoldersFirst', true);

  /// Show tip of suspend
  late final showSuspendTip = property('showSuspendTip', true);

  /// Whether collapse UI items by default
  late final collapseUIDefault = property('collapseUIDefault', true);

  late final serverFuncBtns = listProperty(
    'serverBtns',
    ServerFuncBtn.defaultIdxs,
  );

  /// Docker is more popular than podman, set to `false` to use docker
  late final usePodman = property('usePodman', false);

  /// Try to use `sudo` to run docker command
  late final containerTrySudo = property('containerTrySudo', true);

  /// Keep previous server status when err occurs
  late final keepStatusWhenErr = property('keepStatusWhenErr', false);

  /// Parse container stat
  late final containerParseStat = property('containerParseStat', true);

  /// Auto refresh container status
  late final contaienrAutoRefresh = property('contaienrAutoRefresh', true);

  /// Use double column servers page on Desktop
  late final doubleColumnServersPage = property(
    'doubleColumnServersPage',
    true,
  );

  /// Ignore local network device (eg: br-xxx, ovs-system...)
  /// when building traffic view on server tab
  //late final ignoreLocalNet = property('ignoreLocalNet', true);

  /// Remerber pwd in memory
  /// Used for [DialogX.showPwdDialog]
  late final rememberPwdInMem = property('rememberPwdInMem', true);

  /// SSH Term Theme
  /// 0: follow app theme, 1: light, 2: dark
  late final termTheme = property('termTheme', 0);

  /// Compatiablity for Chinese Android.
  /// Set it to true, if you use Safe Keyboard on Chinese Android
  // late final cnKeyboardComp = property('cnKeyboardComp', false);

  late final lastVer = property('lastVer', 0);

  /// Use CupertinoPageRoute for all routes
  late final cupertinoRoute = property('cupertinoRoute', isIOS);

  /// Hide title bar on desktop
  late final hideTitleBar = property('hideTitleBar', isDesktop);

  /// Display CPU view as progress, also called as old CPU view
  late final cpuViewAsProgress = property('cpuViewAsProgress', false);

  late final displayCpuIndex = property('displayCpuIndex', true);

  late final editorSoftWrap = property('editorSoftWrap', isIOS);

  late final sshTermHelpShown = property('sshTermHelpShown', false);

  late final horizonVirtKey = property('horizonVirtKey', false);

  /// general wake lock
  late final generalWakeLock = property('generalWakeLock', false);

  /// ssh page
  late final sshWakeLock = property('sshWakeLock', true);

  /// fmt: https://example.com/{DIST}-{BRIGHT}.png
  late final serverLogoUrl = property('serverLogoUrl', '');

  late final betaTest = property('betaTest', false);

  /// If it's empty, skip change window size.
  /// Format: {width}x{height}
  late final windowSize = property('windowSize', '');

  late final introVer = property('introVer', 0);

  late final letterCache = property('letterCache', false);

  /// Set it to `$EDITOR`, `vim` and etc. to use remote system editor in SSH terminal.
  /// Set it empty to use local editor GUI.
  late final sftpEditor = property('sftpEditor', '');

  // Never show these settings for users
  //
  // ------BEGIN------

  /// Version of store db
  late final storeVersion = property('storeVersion', 0);

  /// Have notified user for notificaiton permission or not
  late final noNotiPerm = property('noNotiPerm', false);

  // ------END------
}
