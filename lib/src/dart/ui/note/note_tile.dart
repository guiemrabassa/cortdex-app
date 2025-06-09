import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/dart/ui/components/tiles.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/note/utils.dart';
import 'package:cortdex/src/dart/routes/routes.dart';


class NoteTile extends CortdexWidget {
  const NoteTile({super.key, required this.note, required this.onDeleteNote, this.pop = true});

  final Note note;
  final bool pop;

  final Function()? onDeleteNote;

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    void eraseNote() {
      client.run(NoteCommand.delete(id: note.id));
      if (onDeleteNote != null) onDeleteNote!();
    }

    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: note.share,
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: eraseNote),
        children: [
          SlidableAction(
            onPressed: (_) => eraseNote(),
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      // The actual item on the list
      child: TextTile(
        text: note.title,
        onTap: () {
          NoteRoute(id: note.id.toString()).push(context);
          if (pop) Navigator.pop(context);
        },
      ),
    );
  }
}
