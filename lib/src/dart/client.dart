import 'dart:convert';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/helpers/json.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/frb_generated.dart';
import 'package:cortdex/src/rust/inner/command.dart';
import 'package:cortdex/src/rust/inner/server.dart';
import 'package:cortdex/src/rust/third_party/cortdex_db/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/attribute.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';

import 'package:flutter/material.dart';

enum ClientKey implements SettingsKey {
  connection,
  server
}

class Client {
  static const _connKey = 'connection';
  static const _serverKey = 'server';

  // TODO: I should wrap this up in a value state notifier or something
  // that allows the UI to change immediately when connection is lost

  /* CortdexClient? client;
  CortdexServer? server;

  ConnectionSettings get clientSettings => Settings().getOrInsert(ClientKey.connection, () {
      var dir = Settings().mainDir;
      return ConnectionSettings.embedded(
          dbPath: DbPath_Local(path: dir), modelPath: dir);
    }());

  set clientSettings(ConnectionSettings value) => Settings().save(ClientKey.connection, value);

  ServerSettings get serverSettings => Settings().getOrInsert(ClientKey.server, () {
      var dir = Settings().mainDir;
      return ServerSettings(
          port: 9002,
          dbPath: DbPath_Local(path: dir),
          modelPath: dir);
    }());
    
  set serverSettings(ServerSettings value) => Settings().save(ClientKey.server, value);

  static Client? _instance;

  Client._private();

  factory Client() {
    _instance ??= Client._private();
    return _instance!;
  } */

  /* Future<void> startClient() async {
    try {
      client = await CortdexClient.newInstance(kind: clientSettings);
      Log.i('Client started');
    } catch (e) {
      if (e is CortdexErrorImpl) {
        debugPrint((e).getMessage());
      }
    }
  }

  Future<void> startClientWith(ConnectionSettings settings) async {
    client = await CortdexClient.newInstance(kind: settings);
      Log.i('Client started with settings: $settings');
      // If the connection is successful, update the client settings
      clientSettings = settings;
  } */

 /*  Future<CortdexServer> startServer() async {
    if (server == null) {
      try {
        server = await CortdexServer.start(settings: serverSettings);
      } catch (e) {
        if (e is CortdexErrorImpl) {
          debugPrint((e).getMessage());
        }
      }
    }

    return server!;
  }

  Future<CortdexServer> startServerWith(ServerSettings settings) async {
    if (server == null) {
      try {
        Log.i('Starting server');
        server = await CortdexServer.start(settings: settings);
        // Update the server settings if the connection is successful
        serverSettings = settings;
      } catch (e) {
        if (e is CortdexErrorImpl) {
          debugPrint((e).getMessage());
        }
      }
    }

    return server!;
  }

  Future<void> stopServer() async {
    if (server != null) {
      Log.i('Stopping server');
      await server!.stop();
      server = null;
    }
  }

  bool serverStatus() {
    return server != null;
  }

  bool getStatus() {
    return client != null;
  } */
}
/* 
extension CommandProcessor on Client {
  Future<T?> run<T>(Object command, {bool res = true}) async {
    Log.d('Trying to run command: $command');

    ConcreteCortdexCommand ccd = switch (command) {
      AttributeCommand() => command.intoCcd(),
      NoteCommand() => command.intoCcd(),
      NoteQuery() => command.intoCcd(),
      Object() => throw UnimplementedError(),
    };

    Log.d('Trying to run into ccd command: $ccd');

    String? result = await client?.processCommand(command: ccd);

    Log.d('Command run result:\n$result');
    
    if (res && result != null && (result.isNotEmpty)) {
      dynamic json = jsonDecode(result);

      Log.d('Command run json:\n$json');

      return switch (T) {
        const (Note) => CortdexJson.noteFromJson(json),
        const (List<Note>) => (json as List<dynamic>).map((e) => CortdexJson.noteFromJson(e)).toList(),
        const (AttributeWithValue) => CortdexJson.attrWithValueFromJson(json),
        const (List<AttributeWithValue>) => (json as List<dynamic>).map((e) => CortdexJson.attrWithValueFromJson(e)).toList(),
        const (Attribute) => CortdexJson.attrFromJson(json),
        const (List<Attribute>) => (json as List<dynamic>).map((e) => CortdexJson.attrFromJson(e)).toList(),
        Type() => json,
      };
    } else {
      return null;
    }
  }

} */



extension CommandProcessor2 on CortdexClient {
  Future<T?> run<T>(Object command, {bool res = true}) async {
    Log.d('Trying to run command: $command');

    ConcreteCortdexCommand ccd = switch (command) {
      AttributeCommand() => command.intoCcd(),
      NoteCommand() => command.intoCcd(),
      NoteQuery() => command.intoCcd(),
      Object() => throw UnimplementedError(),
    };

    Log.d('Trying to run into ccd command: $ccd');

    String? result = await processCommand(command: ccd);

    Log.d('Command run result:\n$result');
    
    if (res && result != null && (result.isNotEmpty)) {
      // dynamic json = result; // jsonDecode(result);

      // Log.d('Command run json:\n$json');

      return CortdexJson.fromJson(result);

      /* return switch (T) {
        const (Note) => CortdexJson.fromJson(json),
        const (List<Note>) => (json as List<dynamic>).map((e) => CortdexJson.fromJson(e)).toList(),
        const (AttributeWithValue) => CortdexJson.fromJson(json),
        const (List<AttributeWithValue>) => (json as List<dynamic>).map((e) => CortdexJson.fromJson(e)).toList(),
        const (Attribute) => CortdexJson.fromJson(json),
        const (List<Attribute>) => (json as List<dynamic>).map((e) => CortdexJson.fromJson(e)).toList(),
        Type() => json,
      }; */
    } else {
      return null;
    }
  }

}