import 'package:cortdex/src/dart/client/client.dart' show clientProvider;
import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/server/server.dart';
import 'package:cortdex/src/dart/settings/client.dart';
import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:cortdex/src/dart/ui/settings/model.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/dart/ui/field.dart';
import 'package:cortdex/src/dart/ui/settings/settings.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_db/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClientSettingsPage extends HookConsumerWidget {
  const ClientSettingsPage({super.key});

  static Widget _buildEmbedded(
    BuildContext context,
    WidgetRef ref,
  ) {
    ConnectionSettings_Embedded settings = ConnectionSettings_Embedded(
      dbPath: DbPath_Local(path: Settings().mainDir),
      modelPath: Settings().mainDir,
    );

    if (Settings().clientSettings is ConnectionSettings_Embedded) {
      settings = Settings().clientSettings as ConnectionSettings_Embedded;
    }

    return Column(
      children: [
        ModelSelector(),
        GoodText(
          context.lang.local_(context.lang.settings_(context.lang.client)),
          type: TextType.button,
        ),
        _buildDbSettings(context, settings.dbPath, (db) {
          settings = settings.copyWith(dbPath: db);
        }),
        ListTile(
          title: GoodText(
            context.lang.startThe(context.lang.connection),
            type: TextType.button,
          ),
          onTap: () async {
            final start = ref.watch(clientProvider.start);

            Log.d('Trying to start with $settings!');

            await start(settings);

            Log.d('Started!');
            // await Client().startClientWith(settings);
          },
        ),
      ],
    );
  }

  static Widget _buildRemote(
    BuildContext context,
    ConnectionSettings_Remote settings,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        Text(context.lang.remote_(context.lang.settings_(context.lang.client))),
        LabelWithField(
          label: 'IP:',
          value: settings.host,
          hint: context.lang.inputHint('IP Address'),
          onChanged: (value) => settings = settings.copyWith(host: value),
        ),
        SizedBox(height: 16),
        LabelWithField(
          label: context.lang.port,
          value: settings.port.toString(),
          hint: context.lang.inputHint(context.lang.port),
          onChanged: (value) =>
              settings = settings.copyWith(port: int.tryParse(value) ?? 0),
        ),
        ListTile(
          title: Text(context.lang.connectTo(context.lang.server)),
          onTap: () async {
            final start = ref.watch(clientProvider.start);

            Log.d('Trying to start!');

            await start(settings);

            Log.d('Started!');
            // await Client().startClientWith(settings);
            // await Client().startClientWith(settings);
          },
        ),
      ],
    );
  }

  static Widget _buildServerSettings(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverProvider);

    var ServerSettings(:DbPath dbPath, :String modelPath, :int port) =
        Settings().serverSettings;

    return Column(
      children: [
        Text(context.lang.settings_(context.lang.server)),
        _buildDbSettings(context, dbPath, (db) {
          dbPath = db;
          Settings().serverSettings = Settings().serverSettings.copyWith(dbPath: db);
        }),
        LabelWithField(
          label: '${context.lang.model} ${context.lang.path}',
          hint: context.lang.enter_(
            '${context.lang.model} ${context.lang.path}',
          ),
          value: modelPath,
          onChanged: (value) => modelPath = value,
        ),
        SizedBox(height: 16),
        LabelWithField(
          label: context.lang.port,
          hint: context.lang.enter_(context.lang.port),
          value: port.toString(),
          onChanged: (value) => port = int.tryParse(value) ?? 0,
        ),
        ListTile(
          title: Text(context.lang.startThe(context.lang.server)),
          onTap: () async {
            final start = ref.watch(serverProvider.start);

            await start(
              ServerSettings(port: port, dbPath: dbPath, modelPath: modelPath),
            );
          },
        ),
        ListTile(
          title: Text(
            context.lang.stop_(context.lang.local_(context.lang.server)),
          ),
          onTap: () async {
            final stop = ref.watch(serverProvider.stop);

            await stop();
          },
        ),
      ],
    );
  }

  static Widget _buildDbSettings(
    BuildContext context,
    DbPath savedDbPath,
    Function(DbPath) onDbChanged,
  ) {
    Log.d('Building db settings with :$savedDbPath');
    DbPath_Local localDbPath = DbPath_Local(path: Settings().mainDir);
    DbPath_Remote remoteDbPath = DbPath_Remote(address: 'localhost', port: 80);

    DatabaseType startState;

    switch (savedDbPath) {
      case DbPath_Local():
        localDbPath = savedDbPath;
        startState = DatabaseType.local;
      case DbPath_Remote():
        remoteDbPath = savedDbPath;
        startState = DatabaseType.remote;
    }

    final option = useState(startState);

    List<Widget> options = DatabaseType.values
        .map((e) => GoodText(e.text(context), type: TextType.button))
        .toList();

    final list = <bool>[false, false]..[startState.index] = true;

    final selected = useState(list);

    return Column(
      children: [
        GoodText(
          context.lang.settings_(context.lang.database),
          type: TextType.button,
        ),
        ToggleButtons(
          isSelected: selected.value,
          children: options,
          onPressed: (index) {
            option.value = DatabaseType.values[index];
            for (int i = 0; i < selected.value.length; i++) {
              selected.value[i] = i == index;
            }
          },
        ),
        switch (option.value) {
          DatabaseType.local => Column(
            children: [
              SizedBox(height: 16),
              LabelWithField(
                label: context.lang.path_(context.lang.database),
                hint: context.lang.inputHint(context.lang.path),
                value: localDbPath.path,
                onChanged: (value) {
                  localDbPath = localDbPath.copyWith(path: value);
                },
              ),
            ],
          ),
          DatabaseType.remote => Column(
            children: [
              SizedBox(height: 16),
              LabelWithField(
                label: '${context.lang.database} IP',
                hint: context.lang.inputHint(context.lang.address_('IP')),
                value: remoteDbPath.address,
                onChanged: (value) {
                  remoteDbPath = remoteDbPath.copyWith(address: value);
                },
              ),
              SizedBox(height: 16),
              LabelWithField(
                label: '${context.lang.database} ${context.lang.port}',
                hint: context.lang.inputHint(context.lang.port),
                value: remoteDbPath.port.toString(),
                onChanged: (value) {
                  remoteDbPath = remoteDbPath.copyWith(
                    port: int.tryParse(value) ?? 0,
                  );
                },
              ),
            ],
          ),
        },
        ListTile(
          title: Text(context.lang.saveDbSettings),
          onTap: () {
            DbPath newPath = switch (option.value) {
              DatabaseType.local => localDbPath,
              DatabaseType.remote => remoteDbPath,
            };

            Log.d('Saving database settings $newPath');
            
            onDbChanged(newPath);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLocalServer = useState(false);

    ConnectionSettings_Embedded defaultEmbedded = ConnectionSettings_Embedded(
      dbPath: DbPath_Local(path: Settings().mainDir),
      modelPath: Settings().mainDir,
    );

    ConnectionSettings_Remote remote = ConnectionSettings_Remote(
      host: 'localhost',
      port: 9002,
    );

    ConnectionType startState;

    switch (Settings().clientSettings) {
      case ConnectionSettings_Embedded():
        startState = ConnectionType.embedded;
      case ConnectionSettings_Remote():
        startState = ConnectionType.remote;
    }

    final option = useState(startState);

    List<Widget> options = ConnectionType.values
        .map((e) => GoodText(e.text(context), type: TextType.button))
        .toList();

    final list = <bool>[false, false]..[startState.index] = true;

    final selected = useState(list);

    return SettingsPage(context.lang.connection, [
      ToggleButtons(
        isSelected: selected.value,
        children: options,
        onPressed: (index) {
          option.value = ConnectionType.values[index];
          for (int i = 0; i < selected.value.length; i++) {
            selected.value[i] = i == index;
          }
        },
      ),
      ...switch (option.value) {
        // TODO: Handle this case.
        ConnectionType.embedded => [_buildEmbedded(context, ref)],
        ConnectionType.remote => [
          _buildRemote(context, remote, ref),
          Row(
            children: [
              Text('Use local server'),
              Checkbox(
                value: useLocalServer.value,
                onChanged: (value) => useLocalServer.value = value ?? false,
              ),
            ],
          ),
          if (useLocalServer.value) _buildServerSettings(context, ref),
        ],
      },
    ]);
  }
}
