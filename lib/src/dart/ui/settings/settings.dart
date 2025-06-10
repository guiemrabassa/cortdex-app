

import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/helpers/files.dart';
import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:cortdex/src/dart/ui/components/tiles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsWidget extends HookConsumerWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.lang.settings)),
      body: ListView(
        children: [
          TextTile(
            textAlign: TextAlign.left,
            text: context.lang.connection,
            onTap: () => ConnectionSettingsRoute().push(context),
          ),
          TextTile(
            textAlign: TextAlign.left,
            text: context.lang.notes,
            onTap: () => NoteSettingsRoute().push(context),
          ),
          TextTile(
            textAlign: TextAlign.left,
            text: context.lang.eraseAllSettings,
            onTap: () async => await Settings().eraseAll(),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage(this.name, this.children, {super.key});

  final String name;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: GoodText(name, type: TextType.title)),
      body: Wrap(alignment: WrapAlignment.center,children: children,),
    );
  }
}