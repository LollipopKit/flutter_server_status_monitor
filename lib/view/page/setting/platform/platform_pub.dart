import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:server_box/data/res/store.dart';

abstract final class PlatformPublicSettings {
  static Widget buildBioAuthDelay() {
    return FutureWidget<bool>(
      future: BioAuth.isAvail,
      loading: ListTile(
        title: Text(libL10n.bioAuth),
        subtitle: const Text('...', style: UIs.textGrey),
      ),
      error: (e, __) => ListTile(
        title: Text(libL10n.bioAuth),
        subtitle: Text('${libL10n.fail}: $e', style: UIs.textGrey),
      ),
      success: (can) {
        return ListTile(
            title: Text("Delay before locking the app"),
            subtitle: can == true
                ? Text("Wait for 10 seconds before locking the app")
                : const Text(
                    'Not available',
                    style: UIs.textGrey,
                  ),
            trailing: can == true
                ? StoreSwitch(
                    prop: Stores.setting.delayBioAuthLock,
                    callback: (val) async =>
                        Stores.setting.delayBioAuthLock.put(val))
                : null);
      },
    );
  }

  static Widget buildBioAuth() {
    return FutureWidget<bool>(
      future: BioAuth.isAvail,
      loading: ListTile(
        title: Text(libL10n.bioAuth),
        subtitle: const Text('...', style: UIs.textGrey),
      ),
      error: (e, __) => ListTile(
        title: Text(libL10n.bioAuth),
        subtitle: Text('${libL10n.fail}: $e', style: UIs.textGrey),
      ),
      success: (can) {
        return ListTile(
          title: Text(libL10n.bioAuth),
          subtitle: can == true
              ? null
              : const Text(
                  'Not available',
                  style: UIs.textGrey,
                ),
          trailing: can == true
              ? StoreSwitch(
                  prop: Stores.setting.useBioAuth,
                  callback: (val) async {
                    if (val) {
                      Stores.setting.useBioAuth.put(false);
                      return;
                    }
                    // Only auth when turn off (val == false)
                    final result = await BioAuth.goWithResult();
                    // If failed, turn on again
                    if (result != AuthResult.success) {
                      Stores.setting.useBioAuth.put(true);
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}
