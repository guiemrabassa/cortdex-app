import 'dart:convert';

import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_db/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/attribute.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';

import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

class CortdexJson {

  static List<R> _fromJsonList<R extends Object?>(List<dynamic> json) {
    var list = List<R>.empty(growable: true);
    json.forEach((element) {

      var eleme = fromJson<R>(jsonEncode(element));
      if (eleme != null) list.add(eleme);
    });

    return list;
  }

  static T? fromJson<T extends Object?>(String value) {
    var json = jsonDecode(value);

    Log.d('Trying to parse with type $T json: $json');

    if (json is List<dynamic>) {
      
      if (T == List<Note>) {
                  return _fromJsonList<Note>(json) as T?;
                } else if (T == List<Attribute>) {
                  return _fromJsonList<Attribute>(json) as T?;
                } else if (T == List<AttributeWithValue>) {
                  return _fromJsonList<AttributeWithValue>(json) as T?;
                } else if (T == List<AttributeValue>) {
                  return _fromJsonList<AttributeValue>(json) as T?;
                }
    } else if (T == ConnectionSettings) {
      return ConnectionSettings.fromJson(json) as T;
    } else if (T == DbPath) {
      return DbPath.fromJson(json) as T?;
    } else if (T == Note) {
      return _noteFromJson(json) as T;
    } else if (T == Attribute) {
      return _attrFromJson(json) as T;
    } else if (T == AttributeWithValue) {
      return _attrWithValueFromJson(json) as T;
    } else if (T == AttributeValue) {
      return _attributeValueFromDynamic(json) as T;
    }

    throw UnimplementedError();
  }

  static Note _noteFromJson(Map<String, dynamic> json) {
    return Note.raw(
      id: UuidValue.fromString(json['id']),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }

  static Attribute _attrFromJson(Map<String, dynamic> json) {
    return Attribute(
      kind: AttributeKind.fromString(string: json['kind'])!,
      name: json['name'],
      options: json['options'],
    );
  }

  static AttributeWithValue _attrWithValueFromJson(Map<String, dynamic> json) {
    return AttributeWithValue(
      kind: AttributeKind.fromString(string: json['kind'])!,
      name: json['name'],
      noteId: UuidValue.fromString(json['note_id']),
      value: _attributeValueFromDynamic(json['value'])!,
      options: json['options'],
    );
  }

  static AttributeValue? _attributeValueFromDynamic(dynamic rawValue) {
    switch (rawValue) {
      case UuidValue val:
        return AttributeValue.object(val);
      case String val:
        // Defaulting to Text for String.
        // To create AttributeValue.select(String), you'll need a different mechanism
        // as this function cannot distinguish based on type alone.
        return AttributeValue.text(val);
      case int val: // Handle integers
        return AttributeValue.number(val.toDouble());
      case double val: // Handle doubles
        return AttributeValue.number(val);
      case Set<String> val:
        return AttributeValue.multiSelect(val);
      case bool val:
        return AttributeValue.checkbox(val);
      case DateTime val:
        // Defaulting to Datetime for DateTime.
        // To create AttributeValue.date(DateTime) or AttributeValue.time(DateTime),
        // you'll need a different mechanism.
        return AttributeValue.datetime(val);
      default:
        return null;
    }
  }
}

T? fromJson<T extends Object>() {}
