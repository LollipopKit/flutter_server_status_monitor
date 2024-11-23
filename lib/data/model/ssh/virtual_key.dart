import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:server_box/core/extension/context/locale.dart';
import 'package:server_box/data/res/store.dart';
import 'package:xterm/core.dart';

part 'virtual_key.g.dart';

enum VirtualKeyFunc { toggleIME, backspace, clipboard, snippet, file }

@HiveType(typeId: 4)
enum VirtKey {
  @HiveField(0)
  esc,
  @HiveField(1)
  alt,
  @HiveField(2)
  home,
  @HiveField(3)
  up,
  @HiveField(4)
  end,
  @HiveField(5)
  sftp,
  @HiveField(6)
  snippet,
  @HiveField(7)
  tab,
  @HiveField(8)
  ctrl,
  @HiveField(9)
  left,
  @HiveField(10)
  down,
  @HiveField(11)
  right,
  @HiveField(12)
  clipboard,
  @HiveField(13)
  ime,
  @HiveField(14)
  pgup,
  @HiveField(15)
  pgdn,
  @HiveField(16)
  slash,
  @HiveField(17)
  backSlash,
  @HiveField(18)
  underscore,
  @HiveField(19)
  plus,
  @HiveField(20)
  equal,
  @HiveField(21)
  minus,
  @HiveField(22)
  parenLeft,
  @HiveField(23)
  parenRight,
  @HiveField(24)
  bracketLeft,
  @HiveField(25)
  bracketRight,
  @HiveField(26)
  braceLeft,
  @HiveField(27)
  braceRight,
  @HiveField(28)
  chevronLeft,
  @HiveField(29)
  chevronRight,
  @HiveField(30)
  colon,
  @HiveField(31)
  semicolon,
  ;
}

extension VirtKeyX on VirtKey {
  /// Used for input to terminal
  String? get inputRaw => switch (this) {
        VirtKey.slash => '/',
        VirtKey.backSlash => '\\',
        VirtKey.underscore => '_',
        VirtKey.plus => '+',
        VirtKey.equal => '=',
        VirtKey.minus => '-',
        VirtKey.parenLeft => '(',
        VirtKey.parenRight => ')',
        VirtKey.bracketLeft => '[',
        VirtKey.bracketRight => ']',
        VirtKey.braceLeft => '{',
        VirtKey.braceRight => '}',
        VirtKey.chevronLeft => '<',
        VirtKey.chevronRight => '>',
        VirtKey.colon => ':',
        VirtKey.semicolon => ';',
        _ => null,
      };

  /// Used for displaying on UI
  String get text {
    final t = inputRaw;
    if (t != null) return t;

    if (this == VirtKey.pgdn) return 'PgDn';
    if (this == VirtKey.pgup) return 'PgUp';

    if (name.length > 1) {
      return name.substring(0, 1).toUpperCase() + name.substring(1);
    }
    return name;
  }

  /// Default order of virtual keys
  static const defaultOrder = [
    VirtKey.esc,
    VirtKey.alt,
    VirtKey.home,
    VirtKey.up,
    VirtKey.end,
    VirtKey.sftp,
    VirtKey.snippet,
    VirtKey.tab,
    VirtKey.ctrl,
    VirtKey.left,
    VirtKey.down,
    VirtKey.right,
    VirtKey.clipboard,
    VirtKey.ime,
  ];

  /// Corresponding [TerminalKey]
  TerminalKey? get key => switch (this) {
        VirtKey.esc => TerminalKey.escape,
        VirtKey.alt => TerminalKey.alt,
        VirtKey.home => TerminalKey.home,
        VirtKey.up => TerminalKey.arrowUp,
        VirtKey.end => TerminalKey.end,
        VirtKey.tab => TerminalKey.tab,
        VirtKey.ctrl => TerminalKey.control,
        VirtKey.left => TerminalKey.arrowLeft,
        VirtKey.down => TerminalKey.arrowDown,
        VirtKey.right => TerminalKey.arrowRight,
        VirtKey.pgup => TerminalKey.pageUp,
        VirtKey.pgdn => TerminalKey.pageDown,
        _ => null,
      };

  /// Icons for virtual keys
  IconData? get icon => switch (this) {
        VirtKey.up => Icons.arrow_upward,
        VirtKey.left => Icons.arrow_back,
        VirtKey.down => Icons.arrow_downward,
        VirtKey.right => Icons.arrow_forward,
        VirtKey.sftp => Icons.file_open,
        VirtKey.snippet => Icons.code,
        VirtKey.clipboard => Icons.paste,
        VirtKey.ime => Icons.keyboard,
        _ => null,
      };

  // Use [VirtualKeyFunc] instead of [VirtKey]
  // This can help linter to enum all [VirtualKeyFunc]
  // and make sure all [VirtualKeyFunc] are handled
  VirtualKeyFunc? get func => switch (this) {
        VirtKey.sftp => VirtualKeyFunc.file,
        VirtKey.snippet => VirtualKeyFunc.snippet,
        VirtKey.clipboard => VirtualKeyFunc.clipboard,
        VirtKey.ime => VirtualKeyFunc.toggleIME,
        _ => null,
      };

  bool get toggleable => switch (this) {
        VirtKey.alt || VirtKey.ctrl => true,
        _ => false,
      };

  bool get canLongPress => switch (this) {
        VirtKey.up || VirtKey.left || VirtKey.down || VirtKey.right => true,
        _ => false,
      };

  String? get help => switch (this) {
        VirtKey.sftp => l10n.virtKeyHelpSFTP,
        VirtKey.clipboard => l10n.virtKeyHelpClipboard,
        VirtKey.ime => l10n.virtKeyHelpIME,
        _ => null,
      };

  /// - [saveDefaultIfErr] if the stored raw values is invalid, save default order to store
  static List<VirtKey> loadFromStore({bool saveDefaultIfErr = true}) {
    try {
      final ints = Stores.setting.sshVirtKeys.fetch();
      return ints.map((e) => VirtKey.values[e]).toList();
    } on RangeError {
      final ints = defaultOrder.map((e) => e.index).toList();
      Stores.setting.sshVirtKeys.put(ints);
    } catch (e, s) {
      Loggers.app.warning('Failed to load sshVirtKeys', e, s);
    }
    return defaultOrder;
  }
}
