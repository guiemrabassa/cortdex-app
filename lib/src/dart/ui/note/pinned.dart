import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:cortdex/src/dart/settings/note.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/dart/ui/components/list.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/dart/ui/note/note_tile.dart';
import 'package:cortdex/src/dart/ui/note/utils.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/src/core.dart';
import 'package:uuid/uuid.dart';

class PinnedNotes extends CortdexWidget {
  const PinnedNotes({super.key});

  Future<List<Note>> getNotes(CortdexClient client) async {
    Log.d('Fetching pinned notes...');
    List<String> pinnedNotes = Settings().getOrInsert(NoteKey.pinnedList, []);
    List<Note> notes = List.empty(growable: true);

    for (var id in pinnedNotes) {
      Note? note = await client.run(
        NoteCommand.get_(id: UuidValue.fromString(id)),
      );
      if (note != null) notes.add(note);
    }

    return notes;
  }

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    return AsyncValueBuilder(
      buildValue: (controller) => getNotes(client),
      onStartup: (controller) {
        Log.d('Adding listener for pinned notes');
        Settings().addListener(
          (SettingEventType type) {
            if (type == SettingEventType.create ||
                type == SettingEventType.update ||
                type == SettingEventType.delete) {
              Log.d('Setting changed event $type. Rebuilding...');
              // Increment the counter to trigger a rebuild
              controller.rebuild();
            }
          },
          NoteKey.pinnedList,
          'PinnedNotes',
        );
      },
      onValue: (controller, value) {
        return DividedList(
          items: value,
          builder: (p0, p1) {
            return NoteTile(
              note: p1,
              onDeleteNote: () {
                HomeRoute().push(context);
              },
              pop: false,
            );
          },
        );
      },
    );
  }
}
