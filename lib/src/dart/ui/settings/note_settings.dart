import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/settings/note.dart';
import 'package:cortdex/src/dart/ui/components/text.dart';
import 'package:cortdex/src/dart/ui/components/toggleable.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/dart/ui/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';

class NoteSettingsPage extends HookConsumerWidget {
  const NoteSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoSave = useState(Settings().getOrInsert(NoteKey.autoSave, true));

    final saveInterval = useState(
      Settings().getOrInsert(NoteKey.saveInterval, 1),
    );

    final saveOnClose = useState(
      Settings().getOrInsert(NoteKey.saveOnClose, true),
    );

    return SettingsPage(context.lang.notes, [
      Row(
        children: [
          GoodText(context.lang.autoSave, type: TextType.button),
          Checkbox(
            value: autoSave.value,
            onChanged: (value) async {
              autoSave.value = value ?? true;
              await Settings().save(NoteKey.autoSave, value);
            },
          ),
          Toggleable(
            Row(
              children: [
                GoodText('${context.lang.interval}:', type: TextType.button),
                NumberPicker(
                  value: saveInterval.value,
                  minValue: 1,
                  maxValue: 60,
                  onChanged: (value) async {
                    saveInterval.value = value;
                    await Settings().save(NoteKey.saveInterval, value);
                  },
                ),
                GoodText(context.lang.seconds, type: TextType.button),
              ],
            ),
            enabled: autoSave.value,
          ),
        ],
      ),
      Row(
        children: [
          GoodText(context.lang.saveOnClose, type: TextType.button),
          Checkbox(
            value: saveOnClose.value,
            onChanged: (value) async {
              saveOnClose.value = value ?? true;
              await Settings().save(NoteKey.saveOnClose, value);
            },
          ),
        ],
      ),
    ]);
  }
}