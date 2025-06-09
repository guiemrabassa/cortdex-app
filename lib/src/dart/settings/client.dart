

import 'package:flutter/material.dart';
import 'package:cortdex/src/dart/helpers/context.dart';



enum ConnectionType { embedded, remote }

extension ConnectionTypeText on ConnectionType {
  String text(BuildContext context) {
    return '${switch (this) {
      ConnectionType.embedded => context.lang.local,
      ConnectionType.remote => context.lang.remote,
    }} ${context.lang.connection}';
  }
}

enum DatabaseType { local, remote }

extension DatabaseTypeText on DatabaseType {
  String text(BuildContext context) {
    return '${switch (this) {
      DatabaseType.local => context.lang.local,
      DatabaseType.remote => context.lang.remote,
    }} ${context.lang.database}';
  }
}