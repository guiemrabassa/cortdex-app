import 'package:cortdex/src/dart/client.dart';
import 'package:cortdex/src/dart/helpers/context.dart';
import 'package:cortdex/src/dart/helpers/debug.dart';
import 'package:cortdex/src/dart/settings/note.dart';
import 'package:cortdex/src/dart/settings/settings.dart';
import 'package:cortdex/src/dart/ui/editor/save_button.dart';
import 'package:cortdex/src/dart/ui/editor/toolbar.dart';
import 'package:cortdex/src/rust/api.dart';
import 'package:cortdex/src/rust/third_party/cortdex_types/api/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cortdex/src/dart/ui/editor/custom_blocks.dart';
import 'package:cortdex/src/dart/ui/note/note_menu.dart';

import 'package:cortdex/src/dart/routes/routes.dart';
import 'package:cortdex/src/dart/ui/cortdex_widget.dart';

import 'package:markdown_quill/markdown_quill.dart';

import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import 'package:markdown/markdown.dart' as md;

class NoteEditorWidget extends AsyncValueWidget<Note> with WindowListener {
  NoteEditorWidget({super.key, required this.id, required this.client});

  final CortdexClient client;

  final UuidValue id;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final QuillController _quillController = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();

  @override
  Future<Note?> buildValue() async {
    Log.d('Entering note with id: $id');

    Note? note = await client.run<Note>(NoteCommand.get_(id: id));

    if (note == null) return null;

    Log.d('Note with title: ${note.title}');

    _titleController.text = note.title;

    final mdDocument = md.Document(encodeHtml: false);
    final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);

    final delta = mdToDelta.convert(note.content);

    try {
      _quillController.document = Document.fromDelta(delta);
    } catch (e) {
      Log.e('Error converting Markdown to Delta: $e');
    }

    return note;
  }

  @override
  Widget onNullValue(BuildContext context, WidgetRef ref) {
    return Center(child: Text(context.lang.notFound(context.lang.note)));
  }

  @override
  Widget onValue(BuildContext context, WidgetRef ref, Note value) {
    final hasChanged = useState(false);

    Future<void> save() async {
      Log.d('Saving');
      var delta = _quillController.document.toDelta();
      var markdown = DeltaToMarkdown().convert(delta);

      client.run(
        NoteCommand.changeContent(id: value.id, newContent: markdown)
      );

      client.run(
        NoteCommand.changeTitle(id: value.id, newTitle: _titleController.text)
      );

      hasChanged.value = false;
    }

    final tickerProvider = useSingleTickerProvider();

    _quillController.document.changes.listen((event) async {
      if (event.source == ChangeSource.local) {
        hasChanged.value = true;
      }
    });

    _titleController.addListener(() async {
      if (_titleController.text.isNotEmpty) {
        hasChanged.value = true;
      }
    });

    /* editor.getChangeStream().listen((event) {
      switch (event) {
        case NoteEditingCommand_ApplyContentDelta():
          Delta delta = Delta.fromJson(jsonDecode(event.field0));
          _quillController.compose(
              delta, _quillController.selection, ChangeSource.remote);
        case NoteEditingCommand_ChangeContent():
          _quillController.document =
              Document.fromDelta(Delta.fromJson(jsonDecode(event.field0)));
          _quillController.document.changes.listen((event) {
            if (event.source == ChangeSource.local) {
              var newContent = jsonEncode(event.change);
              editor.applyContentDelta(delta: newContent);
            }
          });
        case NoteEditingCommand_ChangeTitle():
          _titleController.text = event.field0;

        case NoteEditingCommand_Disconnect():
          debugPrint('Someone disconnected');
      }
    }); */

    useEffect(() {
      if (Settings().getOrInsert(NoteKey.autoSave, true)) {
        final interval = Settings().getOrInsert(NoteKey.saveInterval, 1);
        final ticker = tickerProvider.createTicker((duration) {
          final dif = (duration.inMilliseconds) % (interval * 1000);
          if (dif == 0 && hasChanged.value) {
            save();

            hasChanged.value = false;
          }
        });

        ticker.start();
        return ticker.dispose;
      } else {
        return null;
      }
    }, [tickerProvider]);

    useEffect(() {
      return () async {
        if (Settings().getOrInsert(NoteKey.saveOnClose, true)) await save();
        Log.i('Disconnecting from editor...');
      };
    }, const []);

    List<String> list = Settings().getOrInsert(NoteKey.pinnedList, List.of([]));

    String idStr = id.toString();

    final pinnedText = useState(list.contains(idStr) ? 'Unpin' : 'Pin');

    return Scaffold(
      appBar: AppBar(
        title: TextField(controller: _titleController),
        actions: <Widget>[
          SaveButton(
            onSave: save,
            color: hasChanged.value ? Colors.yellow : Colors.green,
          ),
          PopupMenuButton<void Function()>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: () async {
                    Log.d('${pinnedText.value}ning note with id: $id');

                    if (await Settings().listContains(
                      NoteKey.pinnedList,
                      idStr,
                    )) {
                      Settings().removeFromList(NoteKey.pinnedList, idStr);
                      pinnedText.value = 'Pin';
                    } else {
                      Settings().addToList(NoteKey.pinnedList, idStr);
                      pinnedText.value = 'Unpin';
                    }
                  },
                  child: Text(pinnedText.value),
                ),
                PopupMenuItem(
                  value: () async {
                    Log.d('Deleting note with id: $id');

                    await client.run(NoteCommand.delete(id: id));

                    if (list.contains(idStr)) {
                      list.remove(idStr);
                      await Settings().save(NoteKey.pinnedList, list);
                    }

                    HomeRoute().go(context);
                  },
                  child: Text(context.lang.delete),
                ),
                PopupMenuItem(
                  value: () async {
                    var text = _quillController.document.toPlainText();
                    Log.d('Sharing: \n $text');
                    final box = context.findRenderObject() as RenderBox?;

                    /* await Share.share(
                      text,
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    ); */
                  },
                  child: Text(context.lang.share),
                ),
                PopupMenuItem(
                  value: () {
                    showModalBottomSheet(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      isScrollControlled: true,
                      builder: (context) => NoteMenu(id: id),
                      context: context,
                      isDismissible: true,
                      enableDrag: true,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                    );
                  },
                  child: Text(context.lang.menu),
                ),
              ];
            },
            onSelected: (fn) => fn(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomToolbar(controller: _quillController),
            /* QuillSimpleToolbar(
              controller: _quillController,
              config: QuillSimpleToolbarConfig(
                // embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                showClipboardCopy: false,
                showClipboardCut: false,
                showClipboardPaste: true,
                showBackgroundColorButton: false,
                showColorButton: false,
                
                
                /* customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      _quillController.updateSelection(
                        TextSelection.collapsed(
                          offset: _quillController.selection.extentOffset + 1,
                        ),
                        ChangeSource.local,
                      );
                    },
                  ),
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      _quillController.updateSelection(
                        TextSelection.collapsed(
                          offset: _quillController.selection.extentOffset + 1,
                        ),
                        ChangeSource.local,
                      );
                    },
                  ),
                ], */
                buttonOptions: QuillSimpleToolbarButtonOptions(
                  base: QuillToolbarBaseButtonOptions(
                    afterButtonPressed: () {
                      final isDesktop = {
                        TargetPlatform.linux,
                        TargetPlatform.windows,
                        TargetPlatform.macOS,
                      }.contains(defaultTargetPlatform);
                      if (isDesktop) {
                        _editorFocusNode.requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ), */
            Expanded(
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _quillController,
                config: QuillEditorConfig(
                  embedBuilders: [NotesEmbedBuilder(addEditNote: _addEditNote)],
                  placeholder: context.lang.noteEditorHint,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEditNote(BuildContext context, {Document? document}) async {
    final isEditing = document != null;
    final controller = QuillController(
      document: document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, top: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${isEditing ? context.lang.edit : context.lang.add} ${context.lang.note}',
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: QuillEditor.basic(
          controller: controller,
          config: const QuillEditorConfig(),
        ),
      ),
    );

    if (controller.document.isEmpty()) return;

    final block = BlockEmbed.custom(
      NotesBlockEmbed.fromDocument(controller.document),
    );
    final controller2 = _quillController;
    final index = controller2.selection.baseOffset;
    final length = controller2.selection.extentOffset - index;

    if (isEditing) {
      final offset = getEmbedNode(
        controller2,
        controller2.selection.start,
      ).offset;
      controller2.replaceText(
        offset,
        1,
        block,
        TextSelection.collapsed(offset: offset),
      );
    } else {
      controller2.replaceText(index, length, block, null);
    }
  }

  @override
  void onWindowClose() {
    windowManager.removeListener(this);
    debugPrint('Closing window!');
    // stopNoteEditingSession(editorId: editorId, id: id);
  }

  @override
  List<Object?> conditions() {
    return [id];
  }
}
