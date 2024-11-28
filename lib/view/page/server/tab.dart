import 'dart:async';
import 'dart:math' as math;

import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:server_box/core/extension/context/locale.dart';
import 'package:server_box/core/extension/ssh_client.dart';
import 'package:server_box/data/model/app/shell_func.dart';
import 'package:server_box/data/model/server/try_limiter.dart';
import 'package:server_box/data/res/build_data.dart';
import 'package:server_box/data/res/store.dart';
import 'package:server_box/view/page/server/edit.dart';
import 'package:server_box/view/page/setting/entry.dart';
import 'package:server_box/view/widget/percent_circle.dart';

import 'package:server_box/core/route.dart';
import 'package:server_box/data/model/app/net_view.dart';
import 'package:server_box/data/model/server/server.dart';
import 'package:server_box/data/model/server/server_private_info.dart';
import 'package:server_box/data/provider/server.dart';
import 'package:server_box/view/widget/server_func_btns.dart';

part 'top_bar.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

const _cardPad = 74.0;
const _cardPadSingle = 13.0;
var _cardDesktop = isDesktop ? 160 : 0;

class _ServerPageState extends State<ServerPage>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  late MediaQueryData _media;

  late double _textFactorDouble;
  double _offset = 1;
  late TextScaler _textFactor;

  final _cardsStatus = <String, _CardNotifier>{};

  Timer? _timer;

  final _tag = ''.vn;
  bool _useDoubleColumn = false;

  final _scrollController = ScrollController();
  final _autoHideKey = GlobalKey<AutoHideState>();

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _scrollController.dispose();
    _autoHideKey.currentState?.dispose();
    _tag.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!Stores.setting.fullScreenJitter.fetch()) return;
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _updateOffset();
        setState(() {});
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _media = MediaQuery.of(context);
    _updateOffset();
    _updateTextScaler();
    _useDoubleColumn = _media.size.width > 639 &&
        Stores.setting.doubleColumnServersPage.fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OrientationBuilder(builder: (_, orientation) {
      if (orientation == Orientation.landscape) {
        final useFullScreen = Stores.setting.fullScreen.fetch();
        if (useFullScreen) return _buildLandscape();
      }
      return _buildPortrait();
    });
  }

  Widget _buildPortrait() {
    return Scaffold(
      appBar: _TopBar(
        tags: ServerProvider.tags,
        onTagChanged: (p0) => _tag.value = p0,
        initTag: _tag.value,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _autoHideKey.currentState?.show(),
        child: ListenableBuilder(
          listenable: Stores.setting.textFactor.listenable(),
          builder: (_, __) {
            _updateTextScaler();
            return _buildBody();
          },
        ),
      ),
      floatingActionButton: AutoHide(
        key: _autoHideKey,
        direction: AxisDirection.right,
        offset: 75,
        controller: _scrollController,
        child: FloatingActionButton(
          heroTag: 'addServer',
          onPressed: () => ServerEditPage.route.go(context),
          tooltip: libL10n.add,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLandscape() {
    final offset = Offset(_offset, _offset);
    return Padding(
      // Avoid display cutout
      padding: EdgeInsets.all(_offset.abs()),
      child: Transform.translate(
        offset: offset,
        child: Stack(
          children: [
            _buildLandscapeBody(),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                onPressed: () => SettingsPage.route.go(context),
                icon: const Icon(Icons.settings, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeBody() {
    return ServerProvider.serverOrder.listenVal((order) {
      if (order.isEmpty) {
        return Center(
          child: Text(libL10n.empty, textAlign: TextAlign.center),
        );
      }

      return PageView.builder(
        itemCount: order.length,
        itemBuilder: (_, idx) {
          final id = order[idx];
          final srv = ServerProvider.pick(id: id);
          if (srv == null) return UIs.placeholder;

          return srv.listenVal((srv) {
            final title = _buildServerCardTitle(srv);
            final List<Widget> children = [
              title,
              ..._buildNormalCard(srv.status, srv.spi).joinWith(SizedBox(
                height: _media.size.height / 10,
              ))
            ];

            return Padding(
              padding: _media.padding,
              child: ListenableBuilder(
                listenable: _getCardNoti(id),
                builder: (_, __) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  );
                },
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBody() {
    return ServerProvider.serverOrder.listenVal(
      (order) {
        if (order.isEmpty) {
          return Center(
            child: Text(libL10n.empty, textAlign: TextAlign.center),
          );
        }

        return _tag.listenVal(
          (val) {
            final filtered = _filterServers(order);
            if (_useDoubleColumn &&
                Stores.setting.doubleColumnServersPage.fetch()) {
              return _buildBodyMedium(filtered);
            }
            return _buildBodySmall(filtered: filtered);
          },
        );
      },
    );
  }

  Widget _buildBodySmall({
    required List<String> filtered,
    EdgeInsets? padding = const EdgeInsets.fromLTRB(7, 0, 7, 7),
  }) {
    final count = filtered.length + 1;
    return ListView.builder(
      controller: _scrollController,
      padding: padding,
      itemCount: count,
      itemBuilder: (_, index) {
        // Issue #130
        if (index == count - 1) return UIs.height77;
        final vnode = ServerProvider.pick(id: filtered[index]);
        if (vnode == null) return UIs.placeholder;
        return vnode.listenVal(_buildEachServerCard);
      },
    );
  }

  Widget _buildBodyMedium(List<String> filtered) {
    final mid = (filtered.length / 2).ceil();
    final filteredLeft = filtered.sublist(0, mid);
    final filteredRight = filtered.sublist(mid);
    return Row(
      children: [
        Expanded(
          child: _buildBodySmall(
            filtered: filteredLeft,
            padding: const EdgeInsets.only(left: 7),
          ),
        ),
        Expanded(
          child: _buildBodySmall(
            filtered: filteredRight,
            padding: const EdgeInsets.only(right: 7),
          ),
        )
      ],
    );
  }

  Widget _buildEachServerCard(Server? srv) {
    if (srv == null) {
      return UIs.placeholder;
    }

    return CardX(
      key: Key(srv.spi.id + _tag.value),
      child: InkWell(
        onTap: () {
          if (srv.canViewDetails) {
            AppRoutes.serverDetail(spi: srv.spi).go(context);
          } else {
            ServerEditPage.route.go(context, args: srv.spi);
          }
        },
        onLongPress: () {
          if (srv.conn == ServerConn.finished) {
            final id = srv.spi.id;
            final cardStatus = _getCardNoti(id);
            cardStatus.value = cardStatus.value.copyWith(
              flip: !cardStatus.value.flip,
            );
          } else {
            ServerEditPage.route.go(context, args: srv.spi);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(
            left: _cardPadSingle,
            right: 3,
            top: _cardPadSingle,
            bottom: _cardPadSingle,
          ),
          child: _buildRealServerCard(srv),
        ),
      ),
    );
  }

  /// The child's width mat not equal to 1/4 of the screen width,
  /// so we need to wrap it with a SizedBox.
  Widget _wrapWithSizedbox(Widget child, [bool circle = false]) {
    var width = (_media.size.width - _cardPad - _cardDesktop) / (circle ? 4 : 4.3);
    if (_useDoubleColumn) width /= 2;
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildRealServerCard(Server srv) {
    final id = srv.spi.id;
    final cardStatus = _getCardNoti(id);
    final title = _buildServerCardTitle(srv);

    return ListenableBuilder(
      listenable: cardStatus,
      builder: (_, __) {
        final List<Widget> children = [title];
        if (srv.conn == ServerConn.finished) {
          if (cardStatus.value.flip) {
            children.addAll(_buildFlippedCard(srv));
          } else {
            children.addAll(_buildNormalCard(srv.status, srv.spi));
          }
        }

        final height = _calcCardHeight(srv.conn, cardStatus.value.flip);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 377),
          curve: Curves.fastEaseInToSlowEaseOut,
          height: height,
          // Use [OverflowBox] to dismiss the warning of [Column] overflow.
          child: OverflowBox(
            // If `height == _kCardHeightMin`, the `maxHeight` will be ignored.
            //
            // You can comment the `maxHeight` then connect&disconnect the server
            // to see the difference.
            maxHeight: height != _kCardHeightMin ? height : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFlippedCard(Server srv) {
    const textStyle = TextStyle(color: Colors.grey);
    final children = [
      Btn.column(
        onTap: () => _askFor(
          func: () async {
            if (Stores.setting.showSuspendTip.fetch()) {
              await context.showRoundDialog(
                title: libL10n.attention,
                child: Text(l10n.suspendTip),
              );
              Stores.setting.showSuspendTip.put(false);
            }
            srv.client?.execWithPwd(
              ShellFunc.suspend.exec(srv.spi.id),
              context: context,
              id: srv.id,
            );
          },
          typ: l10n.suspend,
          name: srv.spi.name,
        ),
        icon: const Icon(Icons.stop, color: Colors.grey),
        text: l10n.suspend,
        textStyle: textStyle,
      ),
      Btn.column(
        onTap: () => _askFor(
          func: () => srv.client?.execWithPwd(
            ShellFunc.shutdown.exec(srv.spi.id),
            context: context,
            id: srv.id,
          ),
          typ: l10n.shutdown,
          name: srv.spi.name,
        ),
        icon: const Icon(Icons.power_off, color: Colors.grey),
        text: l10n.shutdown,
        textStyle: textStyle,
      ),
      Btn.column(
        onTap: () => _askFor(
          func: () => srv.client?.execWithPwd(
            ShellFunc.reboot.exec(srv.spi.id),
            context: context,
            id: srv.id,
          ),
          typ: l10n.reboot,
          name: srv.spi.name,
        ),
        icon: const Icon(Icons.restart_alt, color: Colors.grey),
        text: l10n.reboot,
        textStyle: textStyle,
      ),
      Btn.column(
        onTap: () => ServerEditPage.route.go(context, args: srv.spi),
        icon: const Icon(Icons.edit, color: Colors.grey),
        text: libL10n.edit,
        textStyle: textStyle,
      )
    ];

    final width = (_media.size.width - _cardPad - _cardDesktop) / children.length;
    return [
      UIs.height13,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children.map((e) {
          if (width == 0) return e;
          return SizedBox(width: width, child: e);
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildNormalCard(ServerStatus ss, Spi spi) {
    return [
      UIs.height13,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _wrapWithSizedbox(PercentCircle(percent: ss.cpu.usedPercent()), true),
          _wrapWithSizedbox(
            PercentCircle(percent: ss.mem.usedPercent * 100),
            true,
          ),
          _wrapWithSizedbox(_buildNet(ss, spi.id)),
          _wrapWithSizedbox(_buildDisk(ss, spi.id)),
        ],
      ),
      UIs.height13,
      if (Stores.setting.moveServerFuncs.fetch() &&
          // Discussion #146
          !Stores.setting.serverTabUseOldUI.fetch())
        SizedBox(
          height: 27,
          child: ServerFuncBtns(spi: spi),
        ),
    ];
  }

  Widget _buildServerCardTitle(Server s) {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _media.size.width / 2.3),
            child: Text(
              s.spi.name,
              style: UIs.text13Bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_right,
            size: 17,
            color: Colors.grey,
          ),
          const Spacer(),
          _buildTopRightText(s),
          _buildTopRightWidget(s),
        ],
      ),
    );
  }

  Widget _buildTopRightWidget(Server s) {
    final (child, onTap) = switch (s.conn) {
      ServerConn.connecting || ServerConn.loading || ServerConn.connected => (
          SizedBox(
            width: 19,
            height: 19,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(UIs.primaryColor),
            ),
          ),
          null,
        ),
      ServerConn.failed => (
          const Icon(Icons.refresh, size: 21, color: Colors.grey),
          () {
            TryLimiter.reset(s.spi.id);
            ServerProvider.refresh(spi: s.spi);
          },
        ),
      ServerConn.disconnected => (
          const Icon(MingCute.link_3_line, size: 19, color: Colors.grey),
          () => ServerProvider.refresh(spi: s.spi)
        ),
      ServerConn.finished => (
          const Icon(MingCute.unlink_2_line, size: 17, color: Colors.grey),
          () => ServerProvider.closeServer(id: s.spi.id),
        ),
      _ when Stores.setting.serverTabUseOldUI.fetch() => (
          ServerFuncBtnsTopRight(spi: s.spi),
          null,
        ),
    };

    // Or the loading icon will be rescaled.
    final wrapped = child is SizedBox
        ? child
        : SizedBox(height: _kCardHeightMin, width: 27, child: child);
    if (onTap == null) return wrapped.paddingOnly(left: 10);
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: wrapped,
    ).paddingOnly(left: 5);
  }

  Widget _buildTopRightText(Server s) {
    final hasErr = s.conn == ServerConn.failed && s.status.err != null;
    final str = s.getTopRightStr(s.spi);
    if (str == null) return UIs.placeholder;
    return GestureDetector(
      onTap: () {
        if (!hasErr) return;
        _showFailReason(s.status);
      },
      child: Text(str, style: UIs.text13Grey),
    );
  }

  void _showFailReason(ServerStatus ss) {
    final md = '''
${ss.err?.solution ?? l10n.unknown}

```sh
${ss.err?.message ?? 'null'}
''';
    context.showRoundDialog(
      title: libL10n.error,
      child: SingleChildScrollView(child: SimpleMarkdown(data: md)),
      actions: [
        TextButton(
          onPressed: () => Pfs.copy(md),
          child: Text(libL10n.copy),
        )
      ],
    );
  }

  Widget _buildDisk(ServerStatus ss, String id) {
    final cardNoti = _getCardNoti(id);
    return ListenableBuilder(
      listenable: cardNoti,
      builder: (_, __) {
        final isSpeed = cardNoti.value.diskIO ??
            !Stores.setting.serverTabPreferDiskAmount.fetch();

        final (r, w) = ss.diskIO.cachedAllSpeed;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 377),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildIOData(
            isSpeed
                ? '${l10n.read}:\n$r'
                : 'Total:\n${ss.diskUsage?.size.kb2Str}',
            isSpeed
                ? '${l10n.write}:\n$w'
                : 'Used:\n${ss.diskUsage?.used.kb2Str}',
            onTap: () {
              cardNoti.value = cardNoti.value.copyWith(diskIO: !isSpeed);
            },
            key: ValueKey(isSpeed),
          ),
        );
      },
    );
  }

  Widget _buildNet(ServerStatus ss, String id) {
    final cardNoti = _getCardNoti(id);
    final type = cardNoti.value.net ?? Stores.setting.netViewType.fetch();
    final device = ServerProvider.pick(id: id)?.value.spi.custom?.netDev;
    final (a, b) = type.build(ss, dev: device);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 377),
      transitionBuilder: (c, anim) => FadeTransition(opacity: anim, child: c),
      child: _buildIOData(
        a,
        b,
        onTap: () => cardNoti.value = cardNoti.value.copyWith(net: type.next),
        key: ValueKey(type),
      ),
    );
  }

  Widget _buildIOData(
    String up,
    String down, {
    void Function()? onTap,
    Key? key,
  }) {
    final child = Column(
      children: [
        Text(
          up,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
          textScaler: _textFactor,
        ),
        const SizedBox(height: 3),
        Text(
          down,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
          textScaler: _textFactor,
        )
      ],
    );
    if (onTap == null) return child;
    return IconButton(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      onPressed: onTap,
      icon: child,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    ServerProvider.refresh();
    ServerProvider.startAutoRefresh();
  }

  List<String> _filterServers(List<String> order) {
    final tag = _tag.value;
    if (tag == TagSwitcher.kDefaultTag) return order;
    return order.where((e) {
      final tags = ServerProvider.pick(id: e)?.value.spi.tags;
      if (tags == null) return false;
      return tags.contains(tag);
    }).toList();
  }

  static const _kCardHeightMin = 23.0;
  static const _kCardHeightFlip = 99.0;
  static const _kCardHeightNormal = 108.0;
  static const _kCardHeightMoveOutFuncs = 135.0;

  double? _calcCardHeight(ServerConn cs, bool flip) {
    if (_textFactorDouble != 1.0) return null;
    if (cs != ServerConn.finished) {
      return _kCardHeightMin;
    }
    if (flip) {
      return _kCardHeightFlip;
    }
    if (Stores.setting.moveServerFuncs.fetch() &&
        // Discussion #146
        !Stores.setting.serverTabUseOldUI.fetch()) {
      return _kCardHeightMoveOutFuncs;
    }
    return _kCardHeightNormal;
  }

  void _askFor({
    required void Function() func,
    required String typ,
    required String name,
  }) {
    context.showRoundDialog(
      title: libL10n.attention,
      child: Text(libL10n.askContinue('$typ ${l10n.server}($name)')),
      actions: Btn.ok(
        onTap: () {
          context.pop();
          func();
        },
      ).toList,
    );
  }

  _CardNotifier _getCardNoti(String id) => _cardsStatus.putIfAbsent(
        id,
        () => _CardNotifier(const _CardStatus()),
      );

  void _updateOffset() {
    if (!Stores.setting.fullScreenJitter.fetch()) return;
    final x = _media.size.height * 0.03;
    final r = math.Random().nextDouble();
    final n = math.Random().nextBool() ? 1 : -1;
    _offset = x * r * n;
  }

  void _updateTextScaler() {
    _textFactorDouble = Stores.setting.textFactor.fetch();
    _textFactor = TextScaler.linear(_textFactorDouble);
  }
}

typedef _CardNotifier = ValueNotifier<_CardStatus>;

class _CardStatus {
  final bool flip;
  final bool? diskIO;
  final NetViewType? net;

  const _CardStatus({
    this.flip = false,
    this.diskIO,
    this.net,
  });

  _CardStatus copyWith({
    bool? flip,
    bool? diskIO,
    NetViewType? net,
  }) {
    return _CardStatus(
      flip: flip ?? this.flip,
      diskIO: diskIO ?? this.diskIO,
      net: net ?? this.net,
    );
  }
}

extension _ServerX on Server {
  String? getTopRightStr(Spi spi) {
    switch (conn) {
      case ServerConn.disconnected:
        return null;
      case ServerConn.finished:
        // Highest priority of temperature display
        final cmdTemp = () {
          final val = status.customCmds['server_card_top_right'];
          if (val == null) return null;
          // This returned value is used on server card top right, so it should
          // be a single line string.
          return val.split('\n').lastOrNull;
        }();
        final temperatureVal = () {
          // Second priority
          final preferTempDev = spi.custom?.preferTempDev;
          if (preferTempDev != null) {
            final preferTemp = status.sensors
                .firstWhereOrNull((e) => e.device == preferTempDev)
                ?.summary
                ?.split(' ')
                .firstOrNull;
            if (preferTemp != null) {
              return double.tryParse(preferTemp.replaceFirst('°C', ''));
            }
          }
          // Last priority
          final temp = status.temps.first;
          if (temp != null) {
            return temp;
          }
          return null;
        }();
        final upTime = status.more[StatusCmdType.uptime];
        final items = [
          cmdTemp ??
              (temperatureVal != null
                  ? '${temperatureVal.toStringAsFixed(1)}°C'
                  : null),
          upTime
        ];
        final str = items.where((e) => e != null && e.isNotEmpty).join(' | ');
        if (str.isEmpty) return libL10n.empty;
        return str;
      case ServerConn.loading:
        return null;
      case ServerConn.connected:
        return null;
      case ServerConn.connecting:
        return null;
      case ServerConn.failed:
        return status.err != null ? l10n.viewErr : libL10n.fail;
    }
  }
}
