import 'dart:convert';
import 'dart:io';

import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/helpers/files.dart';
import 'package:cortdex/src/dart/helpers/json.dart';
import 'package:cortdex/src/dart/server/server.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_db/api.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as p;

enum SettingEventType { create, read, update, delete }

abstract class SettingsKey {
  SettingsKey();
}

enum MainKey implements SettingsKey { mainDir }

typedef EventCallback = void Function(SettingEventType);

class Settings {
  SharedPreferences _prefs;
  late String mainDir;
  Map<SettingsKey, Map<String, EventCallback>> _listeners = {};

  void _callListeners(SettingEventType type, SettingsKey key) {
    Log.d('Calling listeners for $type on $key');
    if (_listeners.containsKey(key)) {
      for (var listener in _listeners[key]!.values) {
        Log.d(
          'Calling listener for $type on $key : ${_listeners[key]!.length}!',
        );
        listener(type);
      }
    }
  }

  void addListener(EventCallback callback, SettingsKey key, String widgetName) {
    if (!_listeners.containsKey(key)) {
      _listeners[key] = {};
      Log.d('Initializing listeners for $key');
    }

    if (_listeners[key]!.containsKey(widgetName)) {
      Log.d('Listener already exists for $key and widgetName $widgetName!');
    } else {
      _listeners[key]![widgetName] = callback;
      Log.d('Adding listener for $key : ${_listeners[key]!.length}!');
    }
  }

  void removeListener(
    EventCallback callback,
    SettingsKey key,
    String widgetName,
  ) {
    if (_listeners.containsKey(key)) {
      _listeners[key]!.remove(widgetName);
    }
  }

  static Settings? _instance;

  ConnectionSettings get clientSettings =>
      Settings().getOrInsert(ClientKey.connection, () {
        var dir = Settings().mainDir;
        return ConnectionSettings.embedded(
          dbPath: DbPath.local(path: dir),
          modelPath: dir,
        );
      }());

  set clientSettings(ConnectionSettings value) =>
      Settings().save(ClientKey.connection, value);

  ServerSettings get serverSettings =>
      Settings().getOrInsert(ServerKey.settings, () {
        var dir = Settings().mainDir;
        return ServerSettings(
          port: 8000,
          dbPath: DbPath.local(path: dir),
          modelPath: dir,
        );
      }());

  set serverSettings(ServerSettings value) =>
      Settings().save(ServerKey.settings, value);

  factory Settings() {
    _instance ??= Settings();
    return _instance!;
  }

  Settings._private(this._prefs) {
    _prefs = _prefs;
  }

  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _instance = Settings._private(prefs);

    _instance!.mainDir = await _instance!.getOrInsert(
      MainKey.mainDir,
      await () async {
        return (await (Directory(
          p.join((await getMainDirectory()).path, "cortdex"),
        ).create())).path;
      }(),
    );
  }

  Future<bool> eraseAll() async {
    bool erased = await _prefs.clear();
    Log.d('Erased all settings: $erased');
    return erased;
  }

  T? get<T extends Object?>(SettingsKey key, {bool json = false}) {
    _callListeners(SettingEventType.read, key);
    Log.d('Requesting from settings:\nKey: $key Type: $T');

    String keyStr = key.toString();    

    if (!_prefs.containsKey(keyStr)) return null;

    if (T == bool || T == String || T == int || T == double) {
      Log.d('Requesting primitive type');
      final result = _prefs.get(keyStr) as T?;
      Log.d('Found setting value: $result');
      return result;
    } else if (T == List<String>) {
      Log.d('Requesting list type');

      final result = _prefs.getStringList(keyStr);

      Log.d('Found setting list: $result');

      return result as T?;
    } else {
      final result = _prefs.getString(keyStr);
      Log.d('Found setting object: ${result.runtimeType}');
      return _tryFromJson(result, keyStr);
    }
  }

  T getOrInsert<T extends Object>(
    SettingsKey key,
    T defaultValue, {
    bool json = false,
  }) {
    T? queried = get(key);

    if (queried == null) {
      Log.d('Setting default value for key: $key');
      save(key, defaultValue);
      queried = defaultValue;
    }

    return queried;
  }

  Future<bool> addToList(SettingsKey key, String value) async {
    Log.d('Adding to list with key: $key and value: $value');
    final list = getOrInsert<List<String>>(key, <String>[]);
    list.add(value);
    return await save(key, list);
  }

  Future<bool> removeFromList(SettingsKey key, String value) async {
    Log.d('Removing from list with key: $key and value: $value');
    final list = getOrInsert<List<String>>(key, <String>[]);
    list.remove(value);
    return await save(key, list);
  }

  Future<bool> listContains(SettingsKey key, String value) async {
    Log.d('Checking if list contains value: $value with key: $key');
    final list = getOrInsert<List<String>>(key, <String>[]);
    return list.contains(value);
  }

  Future<bool> save<T>(SettingsKey key, T value) async {
    final String keyStr = key.toString();

    Log.d('Inserting into settings:\nKey: $key Value: $value');

    var change = await switch (value) {
      bool value => _prefs.setBool(keyStr, value),
      int value => _prefs.setInt(keyStr, value),
      double value => _prefs.setDouble(keyStr, value),
      String value => _prefs.setString(keyStr, value),
      List<Object> value => () {
        Log.d('Saving list of strings:\nKey: $keyStr Value: $value');
        return _prefs.setStringList(keyStr, value as List<String>);
      }(),
      _ => _trySetObject(keyStr, value),
    };

    if (change == true) {
      if (_prefs.containsKey(key.toString())) {
        _callListeners(SettingEventType.update, key);
      } else {
        _callListeners(SettingEventType.create, key);
      }
    }

    return change;
  }

  Future<bool> _trySetObject<T>(String keyStr, T value) async {
    try {
      final json = jsonEncode(value);
      Log.d('Saving object:\nKey: $keyStr Value: $json');
      return _prefs.setString(keyStr, json);
    } catch (e) {
      Log.e('Failed to save with key: $keyStr object: $value');
      return false;
    }
  }

  T? _tryFromJson<T>(String? value, String keyStr) {
    Log.d('Trying to parse value for key: $value');
    if (value != null) {
      try {
        return CortdexJson.fromJson(value);
      } catch (e) {
        Log.e('Failed to get with key: $keyStr object: $value due to $e');
      }
    }

    return null;
  }
}