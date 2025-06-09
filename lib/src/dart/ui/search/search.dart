import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/ui/components/list.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/note/note_tile.dart';

class SearchDrawer extends CortdexWidget {
  SearchDrawer({super.key});

  final TextEditingController _titleController = TextEditingController(
    text: '',
  );

  @override
  Widget buildWith(BuildContext context, WidgetRef ref, CortdexClient client) {
    final query = useState("");

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
            child: TextField(
              controller: _titleController,
              onChanged: (value) => query.value = value,
            ),
          ),
          NoteListResult(query: query, client: client),
        ],
      ),
    );
  }
}

class NoteListResult extends AsyncValueWidget<List<Note>> {
  const NoteListResult({super.key, required this.query, required this.client});

  final CortdexClient client;

  final ValueNotifier<String> query;

  @override
  List<Object?> conditions() {
    return [query.value];
  }

  @override
  Future<List<Note>?> buildValue() async {
    final command = NoteQuery.basic(amount: BigInt.from(20), text: query.value);
    return await client.run(command);
  }

  @override
  Widget onValue(BuildContext context, WidgetRef ref, List<Note> value) {
    return DividedList(
      items: value,
      builder: (p0, note) => NoteTile(
        note: note,
        onDeleteNote: () {
          query.value = '${query.value} ';
        },
      ),
    );
  }
}
