import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/settings/model.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/frb_generated.dart';
import 'package:riverpod_annotation/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@riverpod
class Client extends _$Client {
  @override
  CortdexClient? build() {
    startSaved();
    return null;
  }

  @mutation
  Future<void> start(ConnectionSettings settings) async {
    try {
      Log.i('Starting client with settings: $settings');

      copyAssetModels();
      
      final newState = await CortdexClient.newInstance(
        kind: Settings().clientSettings,
      );

      await stop();

      Log.i('Client started with settings: $settings');
      Settings().clientSettings = settings;

      Log.i('Old client: $state');

      state = newState;

      Log.i('New client: ${state.toString()}');
    } catch (e) {
      if (e is CortdexErrorImpl) {
        Log.e((e).getMessage());
      }
    }
  }

  @mutation
  Future<void> startSaved() async {
    await start(Settings().clientSettings);
  }

  Future<void> stop() async {
    state?.dispose();
    state = null;
  }
}
