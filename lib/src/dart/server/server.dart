import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/settings/model.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/frb_generated.dart';
import 'package:cortdex/src/rust/inner/server.dart';
import 'package:riverpod_annotation/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

enum ServerKey implements SettingsKey { settings }

@riverpod
class Server extends _$Server {
  @override
  CortdexServer? build() {
    return null;
  }

  @mutation
  Future<void> start(ServerSettings settings) async {
    try {
      Log.i('Starting server with settings: $settings');

      copyAssetModels();

      final newState = await CortdexServer.start(
        settings: Settings().serverSettings,
      );

      Log.i('Server started with settings: $settings');
      Settings().serverSettings = settings;

      Log.i('Old server: $state');

      state = newState;

      Log.i('New server: $state');
    } catch (e) {
      if (e is CortdexErrorImpl) {
        Log.e((e).getMessage());
      }
    }
  }

  @mutation
  Future<void> stop() async {
    await state?.stop();
    state = null;
  }


  @mutation
  Future<void> startSaved() async {
    await start(Settings().serverSettings);
  }

  

}
