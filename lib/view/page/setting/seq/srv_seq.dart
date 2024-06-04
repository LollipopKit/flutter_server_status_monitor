import 'dart:ui';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/core/extension/context/locale.dart';
import 'package:toolbox/data/res/provider.dart';
import 'package:toolbox/data/res/store.dart';

class ServerOrderPage extends StatefulWidget {
  const ServerOrderPage({super.key});

  @override
  State<ServerOrderPage> createState() => _ServerOrderPageState();
}

class _ServerOrderPageState extends State<ServerOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.serverOrder),
      ),
      body: _buildBody(),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(1, 6, animValue)!;
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          // Create a Card based on the color and the content of the dragged one
          // and set its elevation to the animated value.
          child: Card(
            elevation: elevation,
            // color: cards[index].color,
            // child: cards[index].child,
            child: _buildCardTile(index),
          ),
        );
      },
      // child: child,
    );
  }

  Widget _buildBody() {
    if (Pros.server.serverOrder.isEmpty) {
      return Center(child: Text(l10n.noServerAvailable));
    }
    return ReorderableListView.builder(
      footer: const SizedBox(height: 77),
      onReorder: (oldIndex, newIndex) => setState(() {
        Pros.server.serverOrder.move(
          oldIndex,
          newIndex,
          property: Stores.setting.serverOrder,
        );
      }),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      buildDefaultDragHandles: false,
      itemBuilder: (_, idx) => _buildItem(idx),
      itemCount: Pros.server.serverOrder.length,
      proxyDecorator: _proxyDecorator,
    );
  }

  Widget _buildItem(int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey('$index'),
      index: index,
      child: CardX(child: _buildCardTile(index)),
    );
  }

  Widget _buildCardTile(int index) {
    final id = Pros.server.serverOrder[index];
    final spi = Pros.server.pick(id: id)?.spi;
    if (spi == null) {
      return const SizedBox();
    }

    return ListTile(
      title: Text(spi.name),
      subtitle: Text(spi.id, style: UIs.textGrey),
      leading: CircleAvatar(
        child: Text(spi.name[0]),
      ),
      trailing: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
    );
  }
}
